class StopRequest < ActiveRecord::Base
  attr_accessible :from, :vendor
  belongs_to :vendor
  validates_presence_of :from, :vendor
  validates_length_of :from, :maximum => 255

end
