class NscaStatusWorker
  include Sidekiq::Worker
  sidekiq_options queue: :sender,
                  unique: :while_executing,
                  retry: false

  def perform(*args)
    env  = Rails.configuration.datacenter_env
    loc  = Rails.configuration.datacenter_location
    pass = Rails.configuration.nsca_password
    case
    when env.nil?
      logger.warn('NscaStatusWorker: datacenter_env not set')
      return false
    when loc.nil?
      logger.warn('NscaStatusWorker: datacenter_location not set')
      return false
    when pass.nil?
      logger.warn('NscaStatusWorker: nsca_password not set')
      return false
    end

    checks.each do |service, scope|
      count = scope.count
      args  = {
        nscahost:    "#{env}-nagios1.#{loc}.gdi",
        port:        5667,
        hostname:    'xact',
        service:     service,
        return_code: count == 0 ? SendNsca::STATUS_OK : SendNsca::STATUS_WARNING,
        status:      "Status #{count == 0 ? 'OK' : 'WARNING'}: #{count} records",
        password:    pass
      }
      logger.debug("SendNsca::NscaConnection -- #{args.inspect}")
      SendNsca::NscaConnection.new(args).send_nsca
    end
  end

  # noinspection RubyStringKeysInHashInspection
  def checks
    max_not_yet_sending_age = 30.minutes.ago
    max_email_sending_age   = (Rails.configuration.email_delivery_timeout + 3.hours).ago
    max_twilio_sending_age  = (Rails.configuration.twilio_delivery_timeout + 2.hours).ago

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
