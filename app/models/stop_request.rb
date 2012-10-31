class StopRequest < ActiveRecord::Base
  attr_accessible :phone, :country_code, :vendor
  belongs_to :vendor
  validates_presence_of :phone, :country_code, :vendor
  validates_length_of :phone, :maximum => 255
  validates_length_of :country_code, :maximum => 4
  validates_numericality_of :phone, :country_code, :only_integer => true

end
