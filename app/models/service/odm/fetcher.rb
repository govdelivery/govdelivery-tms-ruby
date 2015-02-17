module Service
  module Odm
    class Fetcher
      if defined?(JRUBY_VERSION)
        java_import com.govdelivery.tms.tmsextended.ActivityRequest
      end
      # Abstracts making API calls to ODM. 

      # Fetcher guarantees batch will conform to contract (and that none of the attributes will be nil):
      # Batch = Struct.new(:events -> Enumerable, :next_sequence -> String, :has_more? -> Boolean)
      Batch = Struct.new(:events, :next_sequence, :has_more) do
        def has_more?
          has_more
        end
      end unless defined?(Batch)

      # Params:
      # type    :: "delivery" | "open" | "click"
      # creds   :: com.govdelivery.tms.tmsextended.Credentials
      # service :: TMSExtended_Service.new(URL.new(Rails.configuration.odm_endpoint)).getTMSExtendedPort
      def initialize(type, creds, service, batch_size=Rails.configuration.odm_stats_batch_size)
        raise 'Batch size must be greater than zero.' unless batch_size > 0
        raise 'Type must be one of delivery, open, or click.' unless ["delivery", "open", "click"].include?(type.to_s)
        @type = type
        @creds = creds
        @service = service

        # @batch_size should be immutable! If it changes, activity_request method will need to change!
        @immutable_batch_size = batch_size
      end

      def fetch(sequence)
        activity_batch = @service.send("#{@type}_activity_since", @creds, activity_request(sequence))
        create_batch(activity_batch)
      end

      private

      def create_batch(activity_batch)
        events = activity_batch.send(@type)
        next_sequence = activity_batch.next_sequence
        # as long as we got some results from the last call, and the amount of results returned was the same as the
        # maxResults parameter, we'll assume there are more.
        has_more = events.size == @immutable_batch_size

        Batch.new(events, next_sequence, has_more)
      end

      def activity_request(sequence)
        # as long as @immutable_batch_size is immutable memoizing this is OK
        @_memoized_request ||= create_activity_request
        @_memoized_request.sequence = sequence
        @_memoized_request
      end

      def create_activity_request
        req = ActivityRequest.new
        req.max_results = @immutable_batch_size
        req
      end
    end
  end
end
