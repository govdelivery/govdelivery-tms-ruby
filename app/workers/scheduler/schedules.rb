if $servlet_context
  module Scheduler
    class ScheduleTmsStats < TrinidadScheduler.Cron Rails.configuration.odm_stats_crontab
      def run
        _logger.info("Running #{self.class.name} at #{Time.zone.now}")
        Odm::TmsExtendedStatisticsWorker.perform_async
      end
    end


    class ScheduleTwilioSmsPoll < TrinidadScheduler.Cron Rails.configuration.twilio_sms_poll_crontab
      def run
        _logger.info("Running #{self.class.name} at #{Time.zone.now}")
        Twilio::VoicePollingWorker.perform_async
      end
    end


    class ScheduleTwilioVoicePoll < TrinidadScheduler.Cron Rails.configuration.twilio_voice_poll_crontab
      def run
        _logger.info("Running #{self.class.name} at #{Time.zone.now}")
        Twilio::SmsPollingWorker.perform_async
      end
    end

    class ScheduleMessageCompletionCheck < TrinidadScheduler.Cron Rails.configuration.message_completion_crontab
      def run
        _logger.info("Running #{self.class.name} at #{Time.zone.now}")
        CheckMessagesForCompletion.perform_async
      end
    end

  end
end