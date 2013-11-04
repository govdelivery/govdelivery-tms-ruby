require 'base'

class CheckMessagesForCompletion
  include Workers::Base
  include Sidetiq::Schedulable

  sidekiq_options unique: true, retry: false

  recurrence do
    eval(Rails.configuration.message_completion_crontab)
  end

  def perform(*args)
    [SmsMessage, VoiceMessage, EmailMessage].each do |message_class|
      do_completion_check(message_class)
    end
  end

  def do_completion_check(klass)
    klass.sending.find_each do |message|
      logger.debug("Checking completion status for message #{message.class.name} #{message.id}")
      message.check_complete!
    end
  end

end
