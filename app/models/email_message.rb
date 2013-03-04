class EmailMessage < ActiveRecord::Base
  include Message

  attr_accessible :subject, :body, :from_name

  validates :body, presence: true
  validates :subject, presence: true, length: {maximum: 400}

  delegate :from_email, :to => :account
  delegate :from_email, :to => :account


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

  protected

  def recipients_with(type)
    recipients.where(["email_recipients.id in (select distinct(email_recipient_id) from email_recipient_#{type} where email_message_id = ?)", self.id])
  end
end
