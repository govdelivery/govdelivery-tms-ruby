module Odm
  class TmsExtendedStatisticsWorker < Odm::TmsExtendedWorker
    attr_accessor :service
    sidekiq_options unique: true, retry: false, unique_job_expiration: 240 * 60 # 4 hours

    def perform(*args)
      super do
        EmailVendor.tms_extended.find_each { |vendor| process_vendor(vendor) }
      end
    end

    def process_vendor(vendor)
      service.delivery_events(vendor).each do |event|
        with_recipient(event, vendor.recipients.incomplete) do |recipient|
          update_recipient(recipient, event)
        end
      end
    end

    def sent_at(delivery_event)
      Time.at(delivery_event.at.to_gregorian_calendar.time.time / 1000)
    end

    def update_recipient(recipient, delivery_event)
      if delivery_event.delivered?
        recipient.sent!(nil, sent_at(delivery_event))
      else
        # error messages are stored on the value of a delivery_event, just 'cause
        #                 ack, completed_at, error_message
        recipient.failed!(nil, sent_at(delivery_event), delivery_event.value)
      end
    end

    def service
      @service ||= Service::Odm::EventService
    end
  end
end
