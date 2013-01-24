class LoopbackSmsWorker < LoopbackMessageWorker

  def perform(options)
    @message = SmsMessage.find(options['message_id'])
    super
  end

end
