module Mblox
  class SenderWorker < BaseSenderWorker

    sidekiq_options retry: 0, queue: :sender
    delegate :url_helpers, to: "Rails.application.routes"
    RETRY_CODES = [401, 404, 429, 500]

    private

    def send_batch!
      begin
        logger.debug { "Sending message to #{recipient.formatted_phone}" }
        client   = Brick.new(token: vendor.password, service_account_id: vendor.username)
        response = client.create_batch({
          from: vendor.from,
          to: [recipient.formatted_phone],
          callback_url: url_helpers.mblox_url,
          delivery_report: "per_recipient",
          body: Service::SmsBody.annotated(message.body)})
        # batch = Brick::Batch.create({from: vendor.from, to: [recipient.phone], callback_url: url_helpers.mblox_url, delivery_report: "per_recipient", body: message.body})
        logger.info { "Response from MBlox: #{response.inspect}" }
      rescue Brick::Errors::ClientError => e
        raise Sidekiq::Retries::Retry.new(e) if RETRY_CODES.include?(e.response[:status])
        logger.warn { "Non-retryable error from MBlox (#{e.class.name}): #{e.response[:status]} - #{e.try(:message) || 'no message'}" }
        recipient.failed!(nil, nil, e.message)
      rescue StandardError => e
        raise Sidekiq::Retries::Retry.new(e)
      end
      response.try(:id)
    end

  end
end
