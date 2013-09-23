class SmsPrefix < ActiveRecord::Base
  attr_accessible :prefix

  validates :prefix, :presence => true, :uniqueness => {:scope => :sms_vendor_id}
  validates :account, :presence => true
  validate :derived_sms_id

  belongs_to :account, :inverse_of => :sms_prefixes
  belongs_to :sms_vendor

  private

  def derived_sms_id
    self.sms_vendor_id = account.sms_vendor_id unless sms_vendor_id
    errors.add(:sms_vendor, "cannot be blank") unless sms_vendor
  end
end
