class EmailMessage < ActiveRecord::Base
  include Message
  include Personalized

  attr_accessible :body, 
                  :click_tracking_enabled,
                  :from_email,
                  :from_name, 
                  :open_tracking_enabled, 
                  :subject

  validates :body, presence: true
  validates :subject, presence: true, length: {maximum: 400}

  before_create :set_from_email

  def sending!(ack)
    self.ack=ack
    recipients_sending!
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

  def odm_record_designator
    'email::recipient_id'.tap do |s|
      unless macros.blank?
        s << "::" << macros.keys.sort.join("::")
      end
    end
  end

  protected

  def set_from_email
    if from_email.nil?
      self.from_email = account.from_email
    end
  end

  def recipients_with(type)
    recipients.where(["email_recipients.id in (select distinct(email_recipient_id) from email_recipient_#{type} where email_message_id = ?)", self.id])
  end
end
