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

  if defined?(JRUBY_VERSION) && Rails.configuration.odm_polling_enabled
    every(5.minutes, 'Odm::TmsExtendedStatisticsWorker')
    every(5.minutes, 'Odm::TmsExtendedOpensWorker')
    every(5.minutes, 'Odm::TmsExtendedClicksWorker')
    every(5.minutes, 'NscaStatusWorker')
  else
    warn('ODM polling is disabled')
  end

  if Rails.configuration.twilio_polling_enabled
    every(1.hour, 'Twilio::SmsPollingWorker', :at => '**:15')
    every(1.hour, 'Twilio::VoicePollingWorker', :at => '**:45')
  end

  every(1.hour, 'MarkOldRecipientsAsInconclusive', :at => '**:30')

  ['**:00', '**:30'].each do |time|
    every(1.hour, 'Messages::CheckMessagesForCompletion', :at => time)
  end

  begin
    Rails.configuration.custom_report_account_id
    top_of_hour = (0..23).map { |hh| "#{hh}:00" }
    every(1.day, 'Uscmshim12hSubjectSends', at: top_of_hour) { Geckoboard::Uscmshim12hSubjectSends.perform_async(Rails.configuration.custom_report_account_id, 'uscmshim_12h_subject_sends') }
    every(1.day, 'Uscmshim24hSends', at: top_of_hour) { Geckoboard::Uscmshim24hSends.perform_async(Rails.configuration.custom_report_account_id, 'uscmshim_24h_sends') }
    every(5.minutes, 'Uscmshim30mSends') { Geckoboard::Uscmshim30mSends.perform_async(Rails.configuration.custom_report_account_id, 'uscmshim_30m_sends') }
    every(5.minutes, 'Uscmshim30mSubjectSends') { Geckoboard::Uscmshim30mSubjectSends.perform_async(Rails.configuration.custom_report_account_id, 'uscmshim_30m_subject_sends') }
    every(1.day, 'UscmshimReporting', at: top_of_hour) { Geckoboard::UscmshimReporting.perform_async(Rails.configuration.custom_report_account_id, 'CREATED_AT', 'uscmshim_reporting') }
    every(1.day, 'UscmshimClicksReporting', at: top_of_hour) { Geckoboard::UscmshimEventsReporting.perform_async('clicks', Rails.configuration.custom_report_account_id, 'uscmshim_clicks_reporting') }
    every(1.day, 'UscmshimOpensReporting', at: top_of_hour) { Geckoboard::UscmshimEventsReporting.perform_async('opens', Rails.configuration.custom_report_account_id, 'uscmshim_opens_reporting') }
  rescue NoMethodError => e
    Rails.logger.warn("Not scheduling custom reporting jobs: #{e}")
  end


end

