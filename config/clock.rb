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

  if defined?(JRUBY_VERSION) && Rails.configuration.odm_polling_enabled
    every(5.minutes, 'Odm::TmsExtendedStatisticsWorker')
    every(5.minutes, 'Odm::TmsExtendedOpensWorker')
    every(5.minutes, 'Odm::TmsExtendedClicksWorker')
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
    top_of_hour = (0..23).map { |hh| "#{hh}:00" }

    every(1.day, 'GeckboardTwelveHourSubjectSends', at: top_of_hour) {Geckoboard::PeriodicReporting.perform_async('TwelveHourSubjectSends', '12h_subject_sends') }
    every(1.day, 'GeckboardOneDaySends', at: top_of_hour) {Geckoboard::PeriodicReporting.perform_async('OneDaySends', '24h_sends') }
    every(5.minutes, 'GeckboardThirtyMinuteSends') {Geckoboard::PeriodicReporting.perform_async('ThirtyMinuteSends', '30m_sends') }
    every(5.minutes, 'GeckboardThirtyMinuteSubjectSends') {Geckoboard::PeriodicReporting.perform_async('ThirtyMinuteSubjectSends', '30m_subject_sends') }
    every(1.day, 'GeckboardReporting', at: top_of_hour) {Geckoboard::PeriodicReporting.perform_async('Reporting', 'reporting', 'CREATED_AT') }
    every(1.day, 'GeckboardClicksReporting', at: top_of_hour) {Geckoboard::PeriodicReporting.perform_async('EventsReporting', 'clicks_reporting', 'clicks') }
    every(1.day, 'GeckboardOpensReporting', at: top_of_hour) {Geckoboard::PeriodicReporting.perform_async('EventsReporting', 'opens_reporting', 'opens') }

    # Eventually deprecate these
    every(1.day, 'Uscmshim12hSubjectSends', at: top_of_hour) {Geckoboard::TwelveHourSubjectSends.perform_async(Rails.configuration.custom_report_account_id, 'uscmshim_12h_subject_sends')}
    every(1.day, 'Uscmshim24hSends', at: top_of_hour) {Geckoboard::OneDaySends.perform_async(Rails.configuration.custom_report_account_id, 'uscmshim_24h_sends')}
    every(5.minutes, 'Uscmshim30mSends') {Geckoboard::ThirtyMinuteSends.perform_async(Rails.configuration.custom_report_account_id, 'uscmshim_30m_sends')}
    every(5.minutes, 'Uscmshim30mSubjectSends') {Geckoboard::ThirtyMinuteSubjectSends.perform_async(Rails.configuration.custom_report_account_id, 'uscmshim_30m_subject_sends')}
    every(1.day, 'UscmshimReporting', at: top_of_hour) {Geckoboard::Reporting.perform_async(Rails.configuration.custom_report_account_id, 'uscmshim_reporting', 'CREATED_AT')}
    every(1.day, 'UscmshimClicksReporting', at: top_of_hour) {Geckoboard::EventsReporting.perform_async(Rails.configuration.custom_report_account_id, 'uscmshim_clicks_reporting', 'clicks')}
    every(1.day, 'UscmshimOpensReporting', at: top_of_hour) {Geckoboard::EventsReporting.perform_async(Rails.configuration.custom_report_account_id, 'uscmshim_opens_reporting', 'opens')}
  rescue => e
    Rails.logger.warn("Not scheduling custom reporting jobs: #{e}")
  end
end
