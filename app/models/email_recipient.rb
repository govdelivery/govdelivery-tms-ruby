class EmailRecipient < ActiveRecord::Base
  include Recipient

  attr_accessible :email
  validates_presence_of :message
  validates :email, :presence => true, length: {maximum: 256}

end
