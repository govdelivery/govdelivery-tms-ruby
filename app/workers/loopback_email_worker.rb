class LoopbackEmailWorker < LoopbackMessageWorker
  include Workers::Base
  sidekiq_options retry: false

  def perform(options)
    @message = EmailMessage.find(options['message_id'])
    super
  end

end
