require 'base'

module Odm
  class ThrottledTmsExtendedSenderWorker < Odm::TmsExtendedSenderWorker
    def perform(options)
      # Nothing should be processing jobs out of the cms_throttled queue. It's
      # just a holding queue for the CmsThrottledWorker to pull from.
      Rails.logger.error('something is processing throttled jobs!!!')
    end

    def self.client_push(item)
      normalized_item = item.merge('class' => self.superclass, 'queue' => 'cms_throttled').stringify_keys
      Sidekiq::Client.push(normalized_item)
    end
  end
end
