class StopRequest < ActiveRecord::Base
  attr_accessible :phone, :vendor
  belongs_to :vendor
  validates_presence_of :phone, :vendor
  validates_length_of :phone, :maximum => 255

end
