module Odm
  class TmsExtendedStatisticsWorker < Odm::TmsExtendedWorker
    include Workers::Base

    def perform(options)
      raise NotImplementedError.new("#{self.class.name} requires JRuby") unless self.class.jruby?

      EmailVendor.tms_extended.find_each { |vendor| process_vendor(vendor) }
    end

    protected

    def process_vendor(vendor)
      delivery_activity = nil
      while (delivery_activity.nil? || (delivery_activity.delivery.size == 1000 && delivery_activity.delivery.size > 0))
        delivery_activity = odm.delivery_activity_since(credentials(vendor), activity_request(vendor))
        process(delivery_activity)
        activity_request.sequence = delivery_activity.next_sequence
      end
    end

    def activity_request(vendor)
      da = ActivityRequest.new
      da.sequence = '0'
      da.max_results = 1000
      da
    end


    def process(delivery_activity)
      delivery_activity.delivery.each do |event|
        rid, rtype = event.recipientID.split('-')
        message_id = event.messageID

        recipient = vendor.recipients.find(rid)
        recipient.complete!(:delivered => event.delivered)
      end
    end
  end
end
