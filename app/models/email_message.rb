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

  before_validation :set_from_email, on: :create
  before_validation :apply_defaults, on: :create

  validates :body, presence: true, on: :create
  validates :subject, presence: true, length: {maximum: 400}, on: :create
  validates :from_email, presence: true
  validates :reply_to, length: {maximum: 255}, format: Devise.email_regexp, allow_blank: true
  validates :errors_to, length: {maximum: 255}, format: Devise.email_regexp, allow_blank: true
  validate :from_email_allowed?

  # This scope is designed to come purely from an index (and avoid hitting the table altogether)
  scope :indexed, -> {select('id, user_id, created_at, status, subject')}

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
    self[:reply_to] || account.reply_to || from_email
  end

  def errors_to
    self[:errors_to] || account.errors_to || from_email
  end

  def odm_record_designator
    'email::recipient_id::x_tms_recipient'.tap do |s|
      s << '::' << macros.keys.sort.join('::') unless macros.blank?
    end
  end

  protected

  def from_email_allowed?
    unless account.from_email_allowed?(from_email)
      errors.add(:from_email, 'is not authorized to send on this account')
    end
  end

  def set_from_email
    self.from_email = account.from_email if from_email.nil? && account
  end

  def apply_defaults
    if email_template
      [:body, :subject, :macros, :open_tracking_enabled, :click_tracking_enabled].select { |attr| self[attr].nil?}.each do |attr|
        self[attr] = email_template[attr] # can't use ||=, it'll overwrite false values
      end
    end
    self.open_tracking_enabled = true if open_tracking_enabled.nil?
    self.click_tracking_enabled = true if click_tracking_enabled.nil?
  end

  def recipients_with(type)
    recipients.where(["email_recipients.id in (select distinct(email_recipient_id) from email_recipient_#{type} where email_message_id = ?)", id])
  end

  def transform_body
    insert_link_tracking_parameters
  end

  def insert_link_tracking_parameters
    return unless tracking_params = [email_template.try(:link_tracking_parameters_hash), account.link_tracking_parameters_hash].detect(&:present?)
    self.body = GovDelivery::Links::Transformer.new(tracking_params).replace_all_hrefs(body)
  end
end
