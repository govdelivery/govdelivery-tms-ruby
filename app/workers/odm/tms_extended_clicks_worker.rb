module Odm
  class TmsExtendedClicksWorker < Odm::TmsExtendedWorker
    sidekiq_options unique: true, retry: false

    def perform(*args)
      raise NotImplementedError.new("#{self.class.name} requires JRuby") unless self.class.jruby?
      EmailVendor.tms_extended.find_each { |vendor| process_vendor(vendor) }
    end

    protected

    def process_vendor(vendor)
      events = Service::Odm::EventService.click_events(vendor)
      events.each do |event|
        begin
          recipient_id = Integer(event.recipient_id)
          logger.debug("Processing message #{event.message_id} sent to #{event.address} (EmailRecipient #{recipient_id})")
          recipient = vendor.recipients.find(recipient_id)
          update_recipient(recipient, event)
        rescue TypeError => e # recipient_id isn't a number
          logger.warn("Couldn't process click activity for message #{event.message_id} sent to #{event.address}: #{e.message}")
        rescue ActiveRecord::RecordNotFound => e
          logger.warn("Couldn't process click activity recipient #{recipient_id} for message #{event.message_id} sent to #{event.address}: #{e.message}")
        end
      end
    end

    def update_recipient(recipient, click_event)
      clicked_at = Time.at(click_event.at.to_gregorian_calendar.time.time/1000)
      recipient.clicked!(click_event.url, clicked_at)
    end
  end
end
