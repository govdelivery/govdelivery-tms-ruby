module Odm
  class TmsExtendedClicksWorker < Odm::TmsExtendedWorker
    sidekiq_options unique: true, retry: false

    def perform(*args)
      super do
        EmailVendor.tms_extended.find_each { |vendor| process_vendor(vendor) }
      end
    end

    def process_vendor(vendor)
      Service::Odm::EventService.click_events(vendor).each do |event|
        with_recipient(event, vendor.recipients) do |recipient|
          update_recipient(recipient, event)
        end
      end
    end

    def update_recipient(recipient, click_event)
      clicked_at = Time.at(click_event.at.to_gregorian_calendar.time_in_millis / 1000)
      recipient.clicked!(click_event.url, clicked_at)
    end
  end
end
