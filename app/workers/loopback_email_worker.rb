class LoopbackEmailWorker < LoopbackMessageWorker
  include Workers::Base
  sidekiq_options retry: 0

  def perform(options)
    @message = EmailMessage.find(options['message_id'])
    super
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
    [
      :magic_sending?,
      :magic_inconclusive?,
      :magic_canceled?,
      :magic_failed?,
      :magic_blacklisted?
    ].none? {|func| self.send(func, recipient)}
  end
end
