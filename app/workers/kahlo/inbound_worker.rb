require 'base'
module Kahlo
  class InboundWorker
    include Workers::Base

    class << self
      attr_writer :client

      def client
        @client ||= GovDelivery::Kahlo::Client.new
      end
    end

    attr_writer :handler

    def handler
      @handler ||= InboundMessageHandler.new
    end

    def perform(sms_params)
      return unless handler.handle(sms_params['id'], sms_params['to'], sms_params['from'], sms_params['body'])
      self.class.client.deliver_message(
        {
          callback_id:  handler.callback_id,
          from:         handler.inbound_recipient,
          to:           handler.outbound_recipient,
          body:         Service::SmsBody.annotated(handler.response_text),
          message_type: Rails.configuration.sms_response_message_type
        })
    rescue ActiveRecord::RecordNotFound
      logger.info("couldn't find vendor for #{sms_params['to']}")
    end
  end
end
