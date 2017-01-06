module Kahlo
  class SenderWorker < BaseSenderWorker

    sidekiq_options retry: 5, queue: :sender

    class << self
      attr_writer :client

      def client
        @client ||= GovDelivery::Kahlo::Client.new
      end
    end

    private

    def send_batch!
      params = recipient.to_kahlo
      params.merge!(message_type: @options[:message_type]) if @options[:message_type]
      self.class.client.deliver_message(params)
      "kahlo" # no need for real acks with kahlo
    end

  end
end
