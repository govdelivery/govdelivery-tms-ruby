return unless $servlet_context

module Scheduler
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

end

