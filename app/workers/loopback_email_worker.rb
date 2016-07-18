class LoopbackEmailWorker < LoopbackMessageWorker
  include Workers::Base
  sidekiq_options retry: 0,
                  queue: :sender,
                  dynamic_queue_key: ->(args) {args['subject'].try(:parameterize)}

  @magic_addresses =     {
    sent:         'sent@sink.govdelivery.com',
    opened:       'opened@sink.govdelivery.com',
    clicked:      'clicked@sink.govdelivery.com',
    blacklisted:  'blacklisted@sink.govdelivery.com',
    failed:       'failed@sink.govdelivery.com',
    bounced:      'bounced@sink.govdelivery.com',
    canceled:     'canceled@sink.govdelivery.com',
    inconclusive: 'inconclusive@sink.govdelivery.com',
    sending:      'sending@sink.govdelivery.com'
  }

  def perform(options)
    @message = EmailMessage.find(options['message_id'])
    super
  end

  def target(recipient)
    recipient.email
  end
end
