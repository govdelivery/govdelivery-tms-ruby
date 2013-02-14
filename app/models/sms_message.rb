class SmsMessage < ActiveRecord::Base
  include Message

  validates_presence_of :body
  validates_length_of :body, :maximum => 160
  attr_accessible :body

  def process_blacklist!
    blacklisted_recipients.find_each do |recipient|
      logger.debug("Marking recipient as BLACKLISTED")
      recipient.blacklist!
    end
  end

  def blacklisted_recipients
    recipients.not_sent.blacklisted(vendor.id)
  end

end