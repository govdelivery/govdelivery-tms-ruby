class EmailMessage < ActiveRecord::Base
  include Message
  include Personalized
  has_many :email_recipient_clicks
  has_many :email_recipient_opens
  belongs_to :email_template

  attr_accessible :body,
                  :click_tracking_enabled,
                  :email_template,
                  :errors_to,
                  :from_email,
                  :from_name,
                  :open_tracking_enabled,
                  :reply_to,
                  :subject

  before_validation :apply_from_email, on: :create
  before_validation :apply_template, on: :create
  before_validation :apply_defaults, on: :create

  validates :body, presence: true, on: :create
  validates :subject, presence: true, length: {maximum: 400}, on: :create
  validates :from_email, presence: true
  validates :reply_to, length: {maximum: 255}, format: Devise.email_regexp, allow_blank: true
  validates :errors_to, length: {maximum: 255}, format: Devise.email_regexp, allow_blank: true
  validates :open_tracking_enabled, :click_tracking_enabled, inclusion: {in: [true, false]}
  validate :from_email_allowed?

  # This scope is designed to come purely from an index (and avoid hitting the table altogether)
  scope :indexed, -> { select('id, user_id, created_at, status, subject, email_template_id') }

  def on_sending(ack=nil)
    self.ack ||= ack
    # ODM vendor sends batch with all recips in message, mark all as sending
    recipients.with_new_status.update_all(status: 'sending', updated_at: Time.now, sent_at: Time.now)
    super
  end

  def recipients_who_clicked
    recipients_with(:clicks)
  end

  def recipients_who_opened
    recipients_with(:opens)
  end

  def recipients_who_failed
    recipients.failed
  end

  def recipients_who_sent
    recipients.sent
  end

  def reply_to
    self[:reply_to] || from_email
  end

  def errors_to
    self[:errors_to] || from_email
  end

  def odm_record_designator
    'email::recipient_id::x_tms_recipient'.tap do |s|
      s << '::' << macros.keys.sort.join('::') unless macros.blank?
    end
  end

  private

  def from_email_allowed?
    unless account.from_email_allowed?(from_email)
      errors.add(:from_email, 'is not authorized to send on this account')
    end
  end

  def apply_from_email
    return unless self.from_email
    apply_from_address(account.from_addresses.find_by_from_email(from_email))
  end

  def apply_from_address(from_address)
    return unless from_address
    [:from_email, :errors_to, :reply_to].each do |attr|
      # if attribute is already set, presumably the client wanted something specific so don't reset it
      self[attr] ||= from_address.send(attr)
    end
  end

  def apply_template
    return unless email_template
    # Using nil as intended - to indicate a variable that has not yet been set
    # Don't use ||= here; false is a value we do not want to override
    [:body, :subject, :macros, :open_tracking_enabled, :click_tracking_enabled].
      select { |attr| self[attr].nil? }.each do |attr|
      self[attr] = email_template[attr] # can't use ||=, it'll overwrite false values
    end
    apply_from_address(email_template.from_address)
  end

  def apply_defaults
    self.open_tracking_enabled  = true if open_tracking_enabled.nil?
    self.click_tracking_enabled = true if click_tracking_enabled.nil?
    apply_from_address(account.default_from_address)
  end

  def recipients_with(type)
    recipients.where(["email_recipients.id in (select distinct(email_recipient_id) from email_recipient_#{type} where email_message_id = ?)", id])
  end

  def transform_body
    insert_link_tracking_parameters
  end

  def insert_link_tracking_parameters
    return unless tracking_params = [email_template.try(:link_tracking_parameters_hash), account.link_tracking_parameters_hash].detect(&:present?)
    self.body = GovDelivery::Links::Transformer.new(tracking_params, use_simple_link_detection: Conf.use_simple_link_detection).replace_all_hrefs(body)
  end

end
