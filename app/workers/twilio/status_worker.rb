require 'base'

module Twilio
  class StatusWorker
    include Workers::Base

    delegate :url_helpers, to: "Rails.application.routes"

    sidekiq_options retry: 0

    def perform(opts)
      opts.symbolize_keys!
      recipient = find_recipient(opts[:sid], opts[:type])
      state_transition = find_transition(opts[:status])
      secondary_status = find_secondary_status(opts[:status], opts[:answered_by])
      begin
        recipient.send(state_transition, opts[:sid], nil, secondary_status)
      rescue Recipient::ShouldRetry # call came back as busy, no answer, or fail...retry
        if recipient.sending?
          logger.info("retrying #{recipient.class.name} #{recipient.id} attempt #{recipient.retries} (#{state_transition} - #{secondary_status})")
          args = {
            message_id:   recipient.message.id,
            recipient_id: recipient.id,
            message_url:  url_helpers.twiml_url,
            callback_url: url_helpers.twilio_status_callbacks_url(format: :xml)
          }
          recipient.message.worker.perform_in(recipient.message.retry_delay.seconds, args)
        end
      end
    end

    protected

    def find_transition(status)
      Service::TwilioResponseMapper.recipient_callback(status)
    end

    def find_secondary_status(secondary, answered_by)
      Service::TwilioResponseMapper.secondary_status(secondary, answered_by)
    end

    def find_recipient(sid, type)
      type == 'sms' ? SmsRecipient.find_by_ack!(sid) : VoiceRecipient.find_by_ack!(sid)
    end
  end
end
