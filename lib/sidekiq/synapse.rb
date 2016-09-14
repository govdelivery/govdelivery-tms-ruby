module Sidekiq
  module Synapse
    BOUNCE_LISTENER = ::Synapse.supervised_subscribe(:tms_bounce_channel, :'xact.bounce_listener',) do |_partition, _offset, _key, message|
      Sidekiq.logger.info { "#{self.class} received #{message}" }
      Analytics::ProcessBounce.perform_async(message)
    end
  end
end

