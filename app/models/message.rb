class Message < ActiveRecord::Base
  attr_accessible :short_body, :recipients_attributes
  
  has_many :recipients, :dependent => :destroy
  accepts_nested_attributes_for :recipients

  belongs_to :user
  validates_presence_of :user
  
  validates_presence_of :short_body
  validates_length_of :short_body, :maximum => 160

  delegate :vendor, :to => :user
end
