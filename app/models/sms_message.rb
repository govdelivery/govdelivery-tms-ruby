class SmsMessage < ActiveRecord::Base
  include Message

  validates :body, presence: { on: :create }, length: { maximum: 160, on: :create }
  attr_accessible :body
  belongs_to :sms_vendor

  before_create :set_sms_vendor

  def blacklisted_recipients
    blacklist_scope(account_id).not_sent
  end

  def blacklist_scope(account_id)
    sms_vendor.shared? ? recipients.account_blacklisted(sms_vendor_id, account_id) : recipients.blacklisted(sms_vendor_id)
  end

  ##
  # override Message#sendable_recipients
  #
  def sendable_recipients
    sms_vendor.shared? ? recipients.to_send(sms_vendor_id, account.id) : recipients.to_send(sms_vendor_id)
  end

  # this is for two-way sms, only one recipient is used
  def first_recipient_id
    recipients.first.id
  end

  protected

  def process_blacklist!
    blacklisted_recipients.find_each do |recipient|
      logger.debug("Marking #{recipient.class.name} #{id} as BLACKLISTED")
      recipient.blacklist!
    end
  end

  def set_sms_vendor
    self.sms_vendor_id = account.sms_vendor_id
  end
end
