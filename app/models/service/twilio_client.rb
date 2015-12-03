module Service
  module TwilioClient
    class Base
      attr_reader :client, :delivery

      def initialize(username, password)
        @client = Twilio::REST::Client.new(username, password)
      end

      def deliver(message, recipient, callback_url, message_url=nil)
        opts = create_options(message, recipient, callback_url, message_url)
        @delivery.create(opts)
      end

      def last_response_code
        @client.last_response.code.to_i
      end

      private

      def create_options(message, recipient, callback_url, message_url=nil)
        opts = {
          to: "#{recipient.formatted_phone}",
          from: message.respond_to?(:from_number) ? message.from_number : message.vendor.from
        }
        opts[:body] = message.body if message.respond_to?(:body)
        opts[:IfMachine] = 'Continue' if message.respond_to?(:play_url) # if voice, use AMD
        opts.tap do |h|
          h[:StatusCallback] = callback_url if callback_url
          h[:url]            = message_url  if message_url
        end
      end
    end
    class Sms < Base
      def initialize(username, password)
        super
        @delivery = client.account.messages
      end
    end
    class Voice < Base
      def initialize(username, password)
        super
        @delivery = client.account.calls
      end
    end
  end
end
