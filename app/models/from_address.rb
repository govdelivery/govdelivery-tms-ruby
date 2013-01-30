class FromAddress < ActiveRecord::Base
  belongs_to :account
  attr_accessible :from_email, :bounce_email, :reply_to_email

  validates :from_email, presence: true, length: {maximum: 255}
  validates :bounce_email, length: {maximum: 255}
  validates :reply_to_email, length: {maximum: 255}

  def bounce_email
    self[:bounce_email] || from_email
  end

  def reply_to_email
    self[:reply_to_email] || from_email
  end
end
