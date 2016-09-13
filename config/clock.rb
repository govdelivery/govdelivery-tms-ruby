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

  begin
    raise 'Rails.configuration.custom_report_account_id not set' unless Rails.configuration.custom_report_account_id
    ten_after_top_of_hour = (0..23).map { |hh| "#{hh}:10" }

    every(1.day, 'GeckboardTwelveHourSubjectSends', at: ten_after_top_of_hour) {Geckoboard::PeriodicReporting.perform_async('TwelveHourSubjectSends', '12h_subject_sends') }
    every(1.day, 'GeckboardOneDaySends', at: ten_after_top_of_hour) {Geckoboard::PeriodicReporting.perform_async('OneDaySends', '24h_sends') }
    every(5.minutes, 'GeckboardThirtyMinuteSends') {Geckoboard::PeriodicReporting.perform_async('ThirtyMinuteSends', '30m_sends') }
    every(5.minutes, 'GeckboardThirtyMinuteSubjectSends') {Geckoboard::PeriodicReporting.perform_async('ThirtyMinuteSubjectSends', '30m_subject_sends') }
    every(1.day, 'GeckboardReporting', at: ten_after_top_of_hour) {Geckoboard::PeriodicReporting.perform_async('Reporting', 'reporting', 'CREATED_AT') }
    every(1.day, 'GeckboardClicksReporting', at: ten_after_top_of_hour) {Geckoboard::PeriodicReporting.perform_async('EventsReporting', 'clicks_reporting', 'clicks') }
    every(1.day, 'GeckboardOpensReporting', at: ten_after_top_of_hour) {Geckoboard::PeriodicReporting.perform_async('EventsReporting', 'opens_reporting', 'opens') }
  rescue => e
    Rails.logger.warn("Not scheduling custom reporting jobs: #{e}")
  end
end
