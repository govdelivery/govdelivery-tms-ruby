module Clockwork
  configure do |config|
    config[:logger] = Rails.logger
  end

  handler do |job|
    job.constantize.perform_async
  end

  if defined?(JRUBY_VERSION) && Rails.configuration.odm_polling_enabled
    every(5.minutes, 'Odm::TmsExtendedStatisticsWorker')

    every(5.minutes, 'Odm::TmsExtendedOpensWorker')
    every(5.minutes, 'Odm::TmsExtendedClicksWorker')
  end

  if Rails.configuration.twilio_polling_enabled
    every(4.hours, 'Twilio::SmsPollingWorker', at: '**:15')
    every(4.hours, 'Twilio::VoicePollingWorker', at: '**:45')
  end

  every(5.minutes, 'CheckMessagesForCompletion')

end

