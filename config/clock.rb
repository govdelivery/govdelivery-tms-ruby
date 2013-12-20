module Clockwork
  configure do |config|
    config[:logger] = Rails.logger
  end

  handler do |job|
    job.constantize.perform_async
  end

  every(5.minutes, 'CheckMessagesForCompletion')

  if defined?(JRUBY_VERSION) && Rails.configuration.odm_polling_enabled
    every(5.minutes, 'Odm::TmsExtendedStatisticsWorker')
    every(5.minutes, 'Odm::TmsExtendedOpensWorker')
    every(5.minutes, 'Odm::TmsExtendedClicksWorker')
  end

  if Rails.configuration.twilio_polling_enabled
    polling_hours = [0, 4, 8, 12, 16, 20]
    every(1.day, 'Twilio::SmsPollingWorker', at: polling_hours.map { |hh| "#{hh}:15" })
    every(1.day, 'Twilio::VoicePollingWorker', at: polling_hours.map { |hh| "#{hh}:45" })
  end

end

