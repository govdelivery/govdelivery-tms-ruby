module Kahlo
  class SenderWorker < BaseSenderWorker

    sidekiq_options retry: 5, queue: :sender
    attr_writer :client

    private

    def send_batch!
      client.deliver_message(recipient.to_kahlo)
      "kahlo" # no need for real acks with kahlo
    end

    def client
      @client ||= GovDelivery::Kahlo::Client.new
    end

  end
end
