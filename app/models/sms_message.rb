class SmsMessage < ActiveRecord::Base
  include Message
  belongs_to :sms_vendor
  belongs_to :sms_template

  attr_accessible :body, :sms_template

  before_create :set_sms_vendor
  before_validation :apply_template, on: :create
  validates :body, presence: {on: :create}, length: {maximum: 160, on: :create}

  def blacklisted_recipients
    recipients.blacklisted(sms_vendor_id, account_id)
  end

  ##
  # override Message#sendable_recipients
  #
  def sendable_recipients
    recipients.to_send(sms_vendor_id, account.id)
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

  private

  def apply_template
    return unless sms_template
    # Using nil as intended - to indicate a variable that has not yet been set
    # Don't use ||= here; false is a value we do not want to override
    [:body].
      select { |attr| self[attr].nil? }.each do |attr|
      self[attr] = sms_template[attr] # can't use ||=, it'll overwrite false values
    end
  end
end
