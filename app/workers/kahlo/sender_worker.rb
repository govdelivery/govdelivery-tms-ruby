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
      self.class.client.deliver_message(recipient.to_kahlo)
      "kahlo" # no need for real acks with kahlo
    end

  end
end
