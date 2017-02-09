module Clockwork
  configure do |config|
    config[:logger] = Rails.logger
  end

  handler do |job|
    job.constantize.perform_async
  end

  error_handler do |error|
    Sidekiq.logger.error("Couldn't execute scheduled job!")
    Sidekiq.logger.error(error)
  end

  every(1.minutes, 'Sidekiq::RateLimitedQueue::LockInvalidator')
  every(5.minutes, 'NscaStatusWorker')

  if Rails.configuration.odm_polling_enabled
    odm_polling_interval = unless %w(qc integration).include? Rails.env.to_s
      5.minutes
    else
      1.minute
    end

    every(odm_polling_interval, 'Odm::TmsExtendedStatisticsWorker')
    every(odm_polling_interval, 'Odm::TmsExtendedOpensWorker')
    every(odm_polling_interval, 'Odm::TmsExtendedClicksWorker')
  else
    warn('ODM polling is disabled')
  end

  if Rails.configuration.twilio_polling_enabled
    every(1.hour, 'Twilio::SmsPollingWorker', at: '**:15')
    every(1.hour, 'Twilio::VoicePollingWorker', at: '**:45')
  end

  every(1.hour, 'MarkOldRecipientsAsInconclusive', at: '**:30')

  ['**:00', '**:30'].each do |time|
    every(1.hour, 'Messages::CheckMessagesForCompletion', at: time)
  end
end
