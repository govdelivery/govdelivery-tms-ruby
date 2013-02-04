class EmailRecipient < ActiveRecord::Base
  include Recipient

  attr_accessible :email
  validates_presence_of :message
  validates :email, :presence => true, length: {maximum: 256}

  def to_odm
    "#{self.email}::#{self.id}"
  end

  def sent!(completed_at)
    update_status!(RecipientStatus::SENT, nil, completed_at: completed_at)
  end

  def failed!(completed_at)
    update_status!(RecipientStatus::FAILED, nil, completed_at: completed_at)
  end

end
