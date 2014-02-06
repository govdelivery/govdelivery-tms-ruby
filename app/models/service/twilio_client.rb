module Service
  module TwilioClient
    class Base
      attr_reader :delivery

      def initialize(delivery)
        @delivery = delivery
      end

      def deliver(message, recipient, callback_url, message_url=nil)
        opts = create_options(message, recipient, callback_url, message_url)
        @delivery.create(opts)
      end

      def last_response_code
        @delivery.last_response.code.to_i
      end

      private

      def twilio_client(username, password)
        Twilio::REST::Client.new(username, password).account
      end

      def create_options(message, recipient, callback_url, message_url=nil)
        opts = {
          :to => "#{recipient.formatted_phone}",
          :from => message.vendor.from,
        }
        opts[:body] = message.body if message.respond_to?(:body)
        opts.tap do |h|
          h[:StatusCallback] = callback_url if callback_url
          h[:url]            = message_url  if message_url
        end
      end
    end
    class Sms < Base
      def initialize(username, password)
        super(twilio_client(username, password).sms.messages)
      end
    end
    class Voice < Base
      def initialize(username, password)
        super(twilio_client(username, password).calls)
      end
    end
  end
end
