require 'app/workers/base'
module Analytics
  class ProcessBounce
    include ::Workers::Base
    sidekiq_options queue: :stats

    def perform(message)
      recipient = EmailRecipient.from_x_tms_recipent(message['recipient'])
      recipient.send("#{message['uri']}!", nil, nil, message['message'])
    rescue ActiveRecord::RecordNotFound => e
      logger.warn("BounceListener: couldn't find EmailRecipient: #{message.inspect} - #{e.message}")
    end
  end
end
