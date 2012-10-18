class Message < ActiveRecord::Base
  attr_accessible :short_body, :completed, :recipients_attributes
  
  has_many :recipients, :dependent => :destroy
  accepts_nested_attributes_for :recipients
  validates_associated :recipients
    
  validates_presence_of :short_body
  validates_length_of :short_body, :maximum => 160
end
