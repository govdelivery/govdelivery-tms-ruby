class LoopbackVoiceWorker < LoopbackMessageWorker

  def perform(options)
    @message = VoiceMessage.find(options['message_id'])
    super
  end

end
