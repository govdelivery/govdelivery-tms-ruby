module Sidekiq
  module Synapse
    BOUNCE_LISTENER = ::Synapse.supervised_subscribe(:tms_bounce_channel, :'xact.bounce_listener',) do |_partition, _offset, _key, message|
      Sidekiq.logger.info { "#{self.class} received #{message}" }
      Analytics::ProcessBounce.perform_async(message)
    end

    KAHLO_STATUS_LISTENER = GovDelivery::Kahlo::Client.new.handle_status_callbacks do |callback|
      Sidekiq.logger.info { "#{self.class} received #{callback}" }
      Kahlo::StatusWorker.perform_async(callback)
    end

    KAHLO_INBOUND_LISTENER = GovDelivery::Kahlo::Client.new.handle_inbound_messages do |sms|
      Sidekiq.logger.info { "#{self.class} received #{sms}" }
      Kahlo::InboundWorker.perform_async(sms)
    end
  end
end
