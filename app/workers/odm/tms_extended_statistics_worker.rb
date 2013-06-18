module Odm
  class TmsExtendedStatisticsWorker < Odm::TmsExtendedWorker
    attr_accessor :service
    sidekiq_options unique: true, retry: false

    def perform(*args)
      raise NotImplementedError.new("#{self.class.name} requires JRuby") unless self.class.jruby?
      EmailVendor.tms_extended.find_each { |vendor| process_vendor(vendor) }
    end

    def process_vendor(vendor)
      events = self.service.delivery_events(vendor)
      events.each do |event|
        begin
          recipient_id = Integer(event.recipient_id)
          logger.debug("Processing message #{event.message_id} sent to #{event.address} (EmailRecipient #{recipient_id})")
          recipient = vendor.recipients.incomplete.find(recipient_id)
          update_recipient(recipient, event)
        rescue ArgumentError, TypeError => e # Raised when recipient_id isn't a number (in which case we got some invalid stats back from ODM, see XACT-126 for example)
          logger.warn("Couldn't process delivery_activity for message #{event.message_id} sent to #{event.address}: #{e.message}")
        rescue ActiveRecord::RecordNotFound => e
          logger.warn("Couldn't process delivery_activity recipient #{recipient_id} for message #{event.message_id} sent to #{event.address}: #{e.message}")
        end
      end
    end

    def update_recipient(recipient, delivery_event)
      sent_at = Time.at(delivery_event.at.to_gregorian_calendar.time.time/1000)
      if delivery_event.delivered?
        recipient.sent!(nil, sent_at)
      else
        recipient.failed!(nil, nil, sent_at)
      end
    end

    def service
      @service ||= Service::Odm::EventService
    end
  end
end
