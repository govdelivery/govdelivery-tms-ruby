class StopRequest < ActiveRecord::Base
  attr_accessible :phone, :vendor
  belongs_to :vendor, :class_name=>'SmsVendor'
  validates_presence_of :phone, :vendor
  validates_length_of :phone, :maximum => 255
  validates_uniqueness_of :phone, :scope => :vendor_id
end
