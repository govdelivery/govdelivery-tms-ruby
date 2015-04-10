class AuthenticationToken < ActiveRecord::Base
  belongs_to :user

  attr_accessible
  validates :token, presence: true, uniqueness: true
  validates :token, :user, presence: true
end
