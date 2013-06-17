class AuthenticationToken < ActiveRecord::Base
  belongs_to :user
  
  validates_uniqueness_of :token
  validates_presence_of :token, :user
end
