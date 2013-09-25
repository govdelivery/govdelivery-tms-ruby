class StopRequest < ActiveRecord::Base
  attr_accessible :phone, :vendor, :account
  belongs_to :vendor, :class_name=>'SmsVendor'
  belongs_to :account
  validates_presence_of :phone, :vendor
  validates_length_of :phone, :maximum => 255
  validates_uniqueness_of :phone, :scope => [:vendor_id, :account_id]
end
