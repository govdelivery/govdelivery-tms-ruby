class LoopbackEmailWorker < LoopbackMessageWorker
  include Workers::Base
  sidekiq_options retry: 0,
                  queue: :sender,
                  dynamic_queue_key:
                    ->(args) {
                      args['subject'].try(:parameterize)
                    }

  def perform(options)
    @message = EmailMessage.find(options['message_id'])
    super
  end

  def magic_new?(recipient)
    false
  end

  def magic_sending?(recipient)
    recipient.email == 'sending@sink.govdelivery.com'
  end

  def magic_inconclusive?(recipient)
    recipient.email == 'inconclusive@sink.govdelivery.com'
  end

  def magic_canceled?(recipient)
    recipient.email == 'canceled@sink.govdelivery.com'
  end

  def magic_failed?(recipient)
    recipient.email == 'failed@sink.govdelivery.com'
  end

  def magic_blacklisted?(recipient)
    recipient.email == 'blacklisted@sink.govdelivery.com'
  end

  def magic_sent?(recipient)
    recipient.email == 'sent@sink.govdelivery.com'
  end
end
