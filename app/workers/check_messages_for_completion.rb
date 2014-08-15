require 'base'

class CheckMessagesForCompletion
  include Workers::Base
  sidekiq_options queue: :stats, unique: true, retry: false, unique_job_expiration: 240 * 60 # 4 hours

  def perform(*args)
    [SmsMessage, VoiceMessage, EmailMessage].each do |message_class|
      do_completion_check(message_class)
    end
  end

  def do_completion_check(klass)
    klass.sending.find_each do |message|
      logger.debug("Checking completion status for message #{message.class.name} #{message.id}")
      message.complete!
    end
  end

end
