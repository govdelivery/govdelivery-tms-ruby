class FromAddress < ActiveRecord::Base
  belongs_to :account
  attr_accessible :email

  validates :email, presence: true, length: {maximum: 255}
end
