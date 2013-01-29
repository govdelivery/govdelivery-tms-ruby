require 'base'

module Odm
  class TmsExtendedSenderWorker < Odm::TmsExtendedWorker

    def perform(options)
      raise NotImplementedError.new("#{self.class.name} requires JRuby") unless self.class.jruby?

      message = EmailMessage.find(options['message_id'])

      msg = ExtendedMessage.new
      msg.subject = message.subject
      msg.body = message.body
      msg.from_name = message.from_name || ''
      msg.from_email = message.from_email

      msg.email_column = 'email'
      msg.record_designator='email'
      message.recipients.find_each { |recipient| msg.to << recipient.email }
      ack = odm.send_message(credentials, msg)
      message.sending!(ack)
    end
  end

end
