class SmsPrefix < ActiveRecord::Base
  attr_accessible :prefix

  validates :prefix, presence: true, uniqueness: { scope: :sms_vendor_id }
  before_validation :derived_sms_id
  validates_presence_of :account, :sms_vendor
  belongs_to :account, inverse_of: :sms_prefixes
  belongs_to :sms_vendor

  def self.account_id_for_prefix(prefix)
    where(' lower(prefix) = ? ', prefix.downcase).pluck(:account_id).first
  end

  private

  def derived_sms_id
    if (did = sms_vendor_id || account.sms_vendor_id).present?
      self.sms_vendor_id = did
    else
      errors.add(:sms_vendor, 'cannot be blank')
      false
    end
  end
end
