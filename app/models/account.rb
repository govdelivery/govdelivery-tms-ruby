class Account < ActiveRecord::Base
  attr_accessible :name, :vendor
  
  has_many :users
  belongs_to :vendor
  
  validates_presence_of :vendor
  
  validates_presence_of :name
  validates_length_of :name, :maximum => 256
end
