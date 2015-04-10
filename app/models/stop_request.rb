class StopRequest < ActiveRecord::Base
  attr_accessible :phone, :vendor, :account
  belongs_to :vendor, class_name: 'SmsVendor'
  belongs_to :account
  validates :phone, presence: true, length: { maximum: 255 }, uniqueness: { scope: [:vendor_id, :account_id] }
  validates :vendor, presence: true
end
