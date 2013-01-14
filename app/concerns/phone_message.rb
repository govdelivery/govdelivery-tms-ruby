module PhoneMessage
  extend ActiveSupport::Concern

  included do
    include Message
    def process_blacklist!
      recipients.incomplete.blacklisted.find_each do |recipient|
        logger.debug("Marking recipient as BLACKLISTED")
        recipient.complete!(:status => Recipient::STATUS_BLACKLISTED)
      end
    end
  end
end




