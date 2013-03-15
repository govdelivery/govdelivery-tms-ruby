module Scheduler
  class ScheduleMessageCompletionCheck < TrinidadScheduler.Cron Rails.configuration.message_completion_crontab
    def run
      _logger.info("Running #{self.class.name} at #{Time.zone.now}")
      CheckMessagesForCompletion.perform_async
    end
  end
end if $servlet_context
