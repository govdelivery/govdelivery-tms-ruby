if Rails.configuration.odm_polling_enabled && $servlet_context
  module Scheduler
    class ScheduleTmsStats < TrinidadScheduler.Cron Rails.configuration.odm_stats_crontab
      def run
        _logger.info("Running #{self.class.name} at #{Time.zone.now}")
        Odm::TmsExtendedStatisticsWorker.perform_async
      end
    end

    class ScheduleTmsOpenStats < TrinidadScheduler.Cron Rails.configuration.odm_opens_crontab
      def run
        _logger.info("Running #{self.class.name} at #{Time.zone.now}")
        Odm::TmsExtendedOpensWorker.perform_async
      end
    end

    class ScheduleTmsClickStats < TrinidadScheduler.Cron Rails.configuration.odm_clicks_crontab
      def run
        _logger.info("Running #{self.class.name} at #{Time.zone.now}")
        Odm::TmsExtendedClicksWorker.perform_async
      end
    end
  end
end