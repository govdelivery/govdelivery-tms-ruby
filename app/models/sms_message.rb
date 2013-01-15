class SmsMessage < ActiveRecord::Base
  include Message

  validates_length_of :body, :maximum => 160
  attr_accessible :body

  def process_blacklist!
    blacklisted_recipients.find_each do |recipient|
      logger.debug("Marking recipient as BLACKLISTED")
      recipient.complete!(:status => RecipientStatus::STATUS_BLACKLISTED)
    end
  end

  def blacklisted_recipients
    recipients.incomplete.blacklisted(vendor.id)
  end

end
