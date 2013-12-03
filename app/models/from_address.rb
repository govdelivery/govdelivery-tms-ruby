class FromAddress < ActiveRecord::Base
  belongs_to :account, :inverse_of => :from_addresses
  attr_accessible :from_email, :bounce_email, :reply_to_email, :is_default

  validates :from_email, presence: true, length: {maximum: 255}
  validates :bounce_email, length: {maximum: 255}
  validates :reply_to_email, length: {maximum: 255}

  before_save :ensure_unique_defaultness

  def bounce_email
    self[:bounce_email] || from_email
  end

  def reply_to_email
    self[:reply_to_email] || from_email
  end

  ##
  # There should only be one default from address at a given time.
  #
  def ensure_unique_defaultness(*args)
    if current_default = account.from_addresses.where(is_default: true).first
      if (self.is_default? && current_default != self)
        current_default.update_attributes(is_default: false)
      end
    else
      self.is_default = true
    end
  end
end
