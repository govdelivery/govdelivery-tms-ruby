class EmailRecipient < ActiveRecord::Base
  include Recipient

  attr_accessible :email
  validates_presence_of :message
  validates :email, :presence => true, length: {maximum: 256}

  def to_odm
    "#{self.email}::#{self.id}"
  end

  def sent!(completed_at)
    update_status!(RecipientStatus::SENT, completed_at)
  end

  def failed!(completed_at)
    update_status!(RecipientStatus::FAILED, completed_at)
  end

  def update_status!(status, completed_at)
    self.completed_at = completed_at
    super(status)
  end

end
