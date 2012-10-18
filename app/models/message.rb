class Message < ActiveRecord::Base
  attr_accessible :short_body, :completed, :recipients_attributes
  
  has_many  :recipients
  accepts_nested_attributes_for :recipients
  
  validates_length_of :short_body, :maximum => 160
  validates_associated :recipients
end
