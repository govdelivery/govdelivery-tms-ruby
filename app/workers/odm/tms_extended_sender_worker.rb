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
      account = message.account
      msg.from_email = account.from_email
      msg.errors_to_email = account.bounce_email
      msg.reply_to_email = account.reply_to_email
      msg.email_column = 'email'
      msg.recipient_id_column = 'recipient_id'
      msg.record_designator='email::recipient_id'
      message.recipients.find_each { |recipient| msg.to << recipient.to_odm }
      ack = odm.send_message(credentials(message.vendor), msg)
      message.sending!(ack)
    end
  end

end
