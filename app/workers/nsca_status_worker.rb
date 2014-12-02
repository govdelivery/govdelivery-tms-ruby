class NscaStatusWorker
  include Sidekiq::Worker
  sidekiq_options queue: :sender, unique: true, retry: false, unique_job_expiration: 1.hour

  def perform(*args)
    env = Rails.configuration.datacenter_env
    loc = Rails.configuration.datacenter_location
    checks.each do |service, scope|
      count = scope.count
      args  = {
        nscahost:    "#{env}-nagios1.#{loc}.gdi",
        port:        5667,
        hostname:    'xact',
        service:     service,
        return_code: count==0 ? SendNsca::STATUS_OK : SendNsca::STATUS_WARNING,
        status:      "Status #{count==0 ? 'OK' : 'WARNING'}: #{count} records"
      }
      logger.debug("SendNsca::NscaConnection -- #{args.inspect}")
      SendNsca::NscaConnection.new(args).send_nsca
    end
  end


  # noinspection RubyStringKeysInHashInspection
  def checks
    max_not_yet_sending_age = 30.minutes.ago
    max_email_sending_age   = 24.hours.ago
    max_twilio_sending_age  = 6.hours.ago

    {
      'Unsent email messages'       => EmailMessage.not_yet_sending.where('sent_at IS NULL OR created_at < ?', max_not_yet_sending_age),
      'Unsent voice messages'       => VoiceMessage.not_yet_sending.where('sent_at IS NULL OR created_at < ?', max_not_yet_sending_age),
      'Unsent SMS messages'         => SmsMessage.not_yet_sending.where('sent_at IS NULL OR created_at < ?', max_not_yet_sending_age),

      'Incomplete email messages'   => EmailMessage.sending.where('sent_at IS NULL OR sent_at < ?', max_email_sending_age),
      'Incomplete voice messages'   => VoiceMessage.sending.where('sent_at IS NULL OR sent_at < ?', max_twilio_sending_age),
      'Incomplete SMS messages'     => SmsMessage.sending.where('sent_at IS NULL OR sent_at < ?', max_twilio_sending_age),

      'Incomplete email recipients' => EmailRecipient.where(status: 'new').where('created_at < ?', max_not_yet_sending_age),
      'Incomplete voice recipients' => VoiceRecipient.where(status: 'new').where('created_at < ?', max_not_yet_sending_age),
      'Incomplete SMS recipients'   => SmsRecipient.where(status: 'new').where('created_at < ?', max_not_yet_sending_age)
    }
  end
end
