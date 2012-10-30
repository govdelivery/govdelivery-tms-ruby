class Vendor < ActiveRecord::Base
  attr_accessible :name, :username, :password, :from, :worker, :help_text

  has_many :accounts

  validates_presence_of [:name, :username, :password, :from, :worker]
  validates_uniqueness_of :name
  validates_length_of [:name, :username, :password, :from, :worker], :maximum => 256
end
