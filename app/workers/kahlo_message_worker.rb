require 'base'
class KahloMessageWorker < BaseMessageWorker
  sidekiq_options retry: 0, queue: :sender

  def perform(options)
    super do
      recipient_batch(message) do |message, recipient|
        Kahlo::SenderWorker.perform_async(message_id: message.id, recipient_id: recipient.id)
      end
    end
  end

end