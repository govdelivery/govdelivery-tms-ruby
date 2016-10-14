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
          callback_id: handler.callback_id,
          from:        handler.to,
          to:          handler.from,
          body:        Service::SmsBody.annotated(handler.response_text)
        })
    end
  end
end