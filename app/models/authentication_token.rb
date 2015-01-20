class AuthenticationToken < ActiveRecord::Base
  belongs_to :user

  attr_accessible
  validates_uniqueness_of :token
  validates_presence_of :token, :user
end
