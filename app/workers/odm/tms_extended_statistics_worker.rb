module Odm
  class TmsExtendedStatisticsWorker < Odm::TmsExtendedWorker
    attr_accessor :service
    sidekiq_options unique: true, retry: false

    def perform(*args)
      raise NotImplementedError.new("#{self.class.name} requires JRuby") unless self.class.jruby?
      EmailVendor.tms_extended.find_each { |vendor| process_vendor(vendor) }
    end

    def process_vendor(vendor)
      self.service.delivery_events(vendor).each do |event|
        with_recipient(event, vendor.recipients.incomplete) do |recipient|
          update_recipient(recipient, event)
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
