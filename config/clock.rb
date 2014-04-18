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

  every(5.minutes, 'CheckMessagesForCompletion')
  every(5.minutes, 'MarkOldRecipientsAsInconclusive')
  every(1.minute, 'CmsThrottledWorker')

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


  begin
    Rails.configuration.custom_report_account_id
    top_of_hour = (0..23).map { |hh| "#{hh}:00" }
    every(1.day, 'Uscmshim24hSends', at: top_of_hour) { Geckoboard::Uscmshim24hSends.perform_async(Rails.configuration.custom_report_account_id, 'uscmshim_24h_sends') }
    every(1.day, 'UscmshimReporting', at: top_of_hour) { Geckoboard::UscmshimReporting.perform_async(Rails.configuration.custom_report_account_id, 'CREATED_AT', 'uscmshim_reporting') }
    every(1.day, 'UscmshimClicksReporting', at: top_of_hour) { Geckoboard::UscmshimEventsReporting.perform_async('clicks', Rails.configuration.custom_report_account_id, 'uscmshim_clicks_reporting') }
    every(1.day, 'UscmshimOpensReporting', at: top_of_hour) { Geckoboard::UscmshimEventsReporting.perform_async('opens', Rails.configuration.custom_report_account_id, 'uscmshim_opens_reporting') }
  rescue NoMethodError => e
    Rails.logger.warn("Not scheduling custom reporting jobs: #{e}")
  end


end

