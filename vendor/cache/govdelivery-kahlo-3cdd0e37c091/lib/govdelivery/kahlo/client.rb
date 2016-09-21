module GovDelivery
  module Kahlo
    class Client
      include ValidationHelper

      class << self
        attr_accessor :topic
        attr_writer :publisher

        def configure
          yield configuration
        end

        def configuration
          Synapse.configuration
        end

        def publisher
          @publisher ||= Synapse
        end
      end

      def initialize
        self.class.topic = 'kahlo_messages'
      end

      def deliver_message(message, opts={validate: true})
        validate(message) if opts[:validate]
        message[:created_at] ||= (Time.now.to_f * 1000).to_i
        self.class.publisher.publish(self.class.topic, message)
      end

      def handle_status_callbacks
        #  Proc::new may be called without a block only within a method with an attached block,
        # in which case that block is converted to the Proc object.
        callback_proc = Proc.new
        Synapse.supervised_subscribe("kahlo_message_statuses") do |_, _, _, message|
          if message['sender_src'] == self.class.configuration.source
            callback_proc.call(message)
          end
        end
      end

      private

      def validate(message)
        raise InvalidMessage.new("Invalid from number: #{message[:from]}", :from) unless plausible_from_number?(message[:from])
        raise InvalidMessage.new("Invalid to number: #{message[:to]}", :to) unless valid_phone?(message[:to])
      end
    end
  end
end