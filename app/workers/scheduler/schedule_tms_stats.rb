if $servlet_context
  module Scheduler
    class ScheduleTmsStats < TrinidadScheduler.Cron Rails.configuration.odm_stats_crontab
      def run
        _logger.info("Running #{self.class.name} at #{Time.zone.now}")
        Odm::TmsExtendedStatisticsWorker.perform_async
      end
    end
  end
end