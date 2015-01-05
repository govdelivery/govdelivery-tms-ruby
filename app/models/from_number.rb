class FromNumber < ActiveRecord::Base
  belongs_to :account, :inverse_of => :from_numbers
  attr_accessible :phone_number, :is_default

  validates :phone_number, presence: true, uniqueness: {scope: :account_id}

  before_save :ensure_unique_defaultness

  ##
  # There should only be one default from address at a given time.
  #
  def ensure_unique_defaultness(*args)
    if current_default = account.from_numbers.where(is_default: true).first
      if (self.is_default? && current_default != self)
        current_default.update_attributes(is_default: false)
      end
    else
      self.is_default = true
    end
  end
end
