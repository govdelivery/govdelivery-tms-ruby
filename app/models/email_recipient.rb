class EmailRecipient < ActiveRecord::Base
  include Recipient

  attr_accessible :email
  validates_presence_of :message
  validates :email, :presence => true, length: {maximum: 256}
  
  has_many :email_recipient_clicks

  def to_odm
    "#{self.email}::#{self.id}"
  end

  def sent!(completed_at)
    update_status!(RecipientStatus::SENT, nil, completed_at: completed_at)
  end

  def failed!(completed_at)
    update_status!(RecipientStatus::FAILED, nil, completed_at: completed_at)
  end

  # Record a click on a URL for this recipient / email combination
  def clicked!(url, date)
    email_recipient_clicks.build.tap do |erc|
      erc.clicked_at = date
      erc.url = url
      erc.email_message = message
      erc.email = email
      erc.save!
    end
  end
end
