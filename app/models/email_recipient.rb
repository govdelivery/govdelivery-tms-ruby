class EmailRecipient < ActiveRecord::Base
  include Recipient

  attr_accessible :email
  validates_presence_of :message
  validates :email, :presence => true, length: {maximum: 256}

  def to_odm
    "#{self.email}::#{self.id}"
  end

  def complete!(attrs)
    return if RecipientStatus.complete?(status)

    self.vendor = message.vendor
    self.status = attrs[:status]

    self.sent_at = Time.now
    self.completed_at = Time.now
    self.save!
  end

end
