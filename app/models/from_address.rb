class FromAddress < ActiveRecord::Base
  belongs_to :account, :inverse_of => :from_addresses
  attr_accessible :from_email, :bounce_email, :errors_to, :reply_to, :reply_to_email, :is_default

  alias_attribute :reply_to, :reply_to_email
  alias_attribute :errors_to, :bounce_email

  validates :from_email, presence: true, length: {maximum: 255}, format: Devise.email_regexp, uniqueness: {scope: :account_id}
  validates :bounce_email,   length: {maximum: 255}, allow_blank: true, format: Devise.email_regexp
  validates :reply_to_email, length: {maximum: 255}, allow_blank: true, format: Devise.email_regexp

  has_many :email_templates

  before_save :ensure_unique_defaultness

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
