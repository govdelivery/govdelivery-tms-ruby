class Vendor < ActiveRecord::Base
  attr_accessible :name, :username, :password, :from

  has_many :accounts
  
  validates_presence_of [:name, :username, :password, :from]
  validates_length_of [:name, :username, :password, :from], :maximum => 256
end
