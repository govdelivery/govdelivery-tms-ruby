module Odm
  class TmsExtendedStatisticsWorker < Odm::TmsExtendedWorker
    sidekiq_options unique: true, retry: false

    def perform(*args)
      raise NotImplementedError.new("#{self.class.name} requires JRuby") unless self.class.jruby?

      logger.debug('hey')
      EmailVendor.tms_extended.find_each { |vendor| process_vendor(vendor) }
    end

    protected

    def process_vendor(vendor)
      delivery_activity = nil
      @activity_request = activity_request(vendor)
      while (delivery_activity.nil? || (delivery_activity.delivery.size == 1000 && delivery_activity.delivery.size > 0))
        logger.debug("Processing ODM data for #{vendor.name} starting from #{vendor.activities_sequence}")
        delivery_activity = odm.delivery_activity_since(credentials(vendor), @activity_request)
        process(delivery_activity, vendor)
        @activity_request.sequence = delivery_activity.next_sequence
      end
      vendor.update_attributes(activities_sequence: delivery_activity.next_sequence)
      logger.debug("Processed ODM data for #{vendor.name} through #{vendor.activities_sequence}")
    end

    def activity_request(vendor)
      da = ActivityRequest.new
      da.sequence = vendor.activities_sequence
      da.max_results = Rails.configuration.odm_stats_batch_size
      da
    end

    def process(delivery_activity, vendor)
      delivery_activity.delivery.each do |event|
        begin
          recipient_id = Integer(event.recipient_id)
          logger.debug("Processing message #{event.message_id} sent to #{event.address} (EmailRecipient #{recipient_id})")
          recipient = vendor.recipients.incomplete.find(recipient_id)
          update_recipient(recipient, event)
        rescue TypeError => e # recipient_id isn't a number
          logger.warn("Couldn't process delivery_activity for message #{event.message_id} sent to #{event.address}: #{e.message}")
        rescue ActiveRecord::RecordNotFound => e
          logger.warn("Couldn't process delivery_activity recipient #{recipient_id} for message #{event.message_id} sent to #{event.address}: #{e.message}")
        end
      end
    end

    def update_recipient(recipient, delivery_event)
      sent_at = Time.at(event.at.to_gregorian_calendar.time.time/1000)
      if delivery_event.delivered?
        recipient.sent!(sent_at)
      else
        recipient.failed!(sent_at)
      end
    end
  end
end
