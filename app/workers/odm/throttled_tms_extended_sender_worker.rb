require 'base'

module Odm
  class ThrottledTmsExtendedSenderWorker < Odm::TmsExtendedSenderWorker
    sidekiq_options queue: 'cms_throttled'

    def perform(options)
      Rails.logger.warn('something is processing throttled jobs!!!')
    end

    def self.client_push(item)
      Sidekiq::Client.push(item.merge('class' => self.superclass, 'queue' => 'cms_throttled').stringify_keys)
    end
  end
end
