class Vendor < ActiveRecord::Base
  attr_accessible :name, :username, :password, :from, :worker

  has_many :accounts
  
  validates_presence_of [:name, :username, :password, :from, :worker]
  validates_length_of [:name, :username, :password, :from, :worker], :maximum => 256
end