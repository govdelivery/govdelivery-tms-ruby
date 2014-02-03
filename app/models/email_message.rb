class EmailMessage < ActiveRecord::Base
  include Message
  include Personalized

  attr_accessible :body, 
                  :click_tracking_enabled,
                  :errors_to,
                  :from_email,
                  :from_name, 
                  :open_tracking_enabled, 
                  :reply_to,
                  :subject

  validates :body, presence: true
  validates :subject, presence: true, length: {maximum: 400}
  validates :from_email, presence: true
  validates :reply_to, length: {maximum: 255}, format: Devise.email_regexp, allow_blank: true
  validates :errors_to, length: {maximum: 255}, format: Devise.email_regexp, allow_blank: true

  before_validation :set_from_email
  validate :from_email_allowed?

  # This scope is designed to come purely from an index (and avoid hitting the table altogether)
  scope :indexed, select("id, user_id, created_at, status, subject")

  def sending!(ack)
    self.ack=ack
    super()
  end

  def recipients_who_clicked
    recipients_with(:clicks)
  end

  def recipients_who_opened
    recipients_with(:opens)
  end

  def open_tracking_enabled=(val)
    val = val.nil? ? true : val
    super val
  end

  def click_tracking_enabled=(val)
    val = val.nil? ? true : val
    super val
  end

  def reply_to
    self[:reply_to] || account.reply_to || self.from_email
  end

  def errors_to
    self[:errors_to] || account.errors_to || self.from_email
  end

  def odm_record_designator
    'email::recipient_id'.tap do |s|
      unless macros.blank?
        s << "::" << macros.keys.sort.join("::")
      end
    end
  end

  protected

  def from_email_allowed?
    unless account.from_email_allowed?(self.from_email)
      errors.add(:from_email, "is not authorized to send on this account")
    end
  end

  def set_from_email
    if from_email.nil? && account
      self.from_email = account.from_email
    end
  end

  def recipients_with(type)
    recipients.where(["email_recipients.id in (select distinct(email_recipient_id) from email_recipient_#{type} where email_message_id = ?)", self.id])
  end
end
