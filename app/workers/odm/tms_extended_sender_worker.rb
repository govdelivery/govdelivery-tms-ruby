require 'base'

module Odm
  class TmsExtendedSenderWorker < Odm::TmsExtendedWorker
  sidekiq_options retry: false

    def perform(options)
      raise NotImplementedError.new("#{self.class.name} requires JRuby") unless self.class.jruby?

      message = EmailMessage.find(options['message_id'])
      macros  = message.macros
      account = message.account
      msg     = ExtendedMessage.new
      
      msg.subject             = message.to_odm(:subject)
      msg.body                = message.to_odm(:body)
      msg.from_name           = message.from_name || ''
      msg.from_email          = account.from_email
      msg.errors_to_email     = account.bounce_email
      msg.reply_to_email      = account.reply_to_email
      
      msg.email_column        = 'email'
      msg.recipient_id_column = 'recipient_id'
      msg.record_designator   = message.odm_record_designator

      msg.track_clicks        = message.click_tracking_enabled?
      msg.track_opens         = message.open_tracking_enabled?

      message.recipients.find_each { |recipient| msg.to << recipient.to_odm(macros) }
      ack = odm.send_message(credentials(message.vendor), msg)
      message.sending!(ack)
    end
  end

end