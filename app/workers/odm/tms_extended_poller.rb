module Odm
  module TmsExtendedPoller
    extend ActiveSupport::Concern

    included do
      include Sidetiq::Schedulable
      if Rails.configuration.odm_polling_enabled
        recurrence do
          eval(Rails.configuration.odm_stats_interval)
        end
      end
    end
  end
end