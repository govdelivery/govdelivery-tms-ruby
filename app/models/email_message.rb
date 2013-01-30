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

  protected

  def recipients_sending!
    self.recipients.update_all(status: RecipientStatus::SENDING, sent_at: Time.now)
  end

end
