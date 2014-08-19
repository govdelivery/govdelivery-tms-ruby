class LoopbackEmailWorker < LoopbackMessageWorker
  include Workers::Base
  sidekiq_options retry: 0

  def perform(options)
    @message = EmailMessage.find(options['message_id'])
    super
  end

end
