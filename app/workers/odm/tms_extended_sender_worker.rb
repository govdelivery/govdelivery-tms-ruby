require 'base'

module Odm
  class TmsExtendedSenderWorker < Odm::TmsExtendedWorker
    sidekiq_options retry:             10,
                    queue:             :sender,
                    dynamic_queue_key: ->(args) {
                      args['subject'].try(:parameterize)
                    }

    def perform(options)
      super { deliver(options['message_id']) }
    end

    def deliver(message_id)
      message, msg, vendor, account =nil
      ActiveRecord::Base.connection_pool.with_connection do
        message = EmailMessage.find(message_id)
        raise "#{message.class.name} #{message.id} is not ready for delivery!" unless message.queued?
        message.class.transaction do
          macros                  = message.macros
          account                 = message.account
          msg                     = ExtendedMessage.new
          msg.subject             = message.to_odm(:subject)
          msg.body                = message.to_odm(:body)
          msg.from_name           = message.from_name || ''
          msg.from_email          = message.from_email
          msg.errors_to_email     = message.errors_to
          msg.reply_to_email      = message.reply_to
          msg.email_column        = 'email'
          msg.recipient_id_column = 'recipient_id'
          msg.record_designator   = message.odm_record_designator
          msg.track_clicks        = message.click_tracking_enabled?
          msg.track_opens         = message.open_tracking_enabled?
          msg.link_encoder        = create_link_encoder(account.link_encoder)
          message.recipients.find_each { |recipient| msg.to << recipient.to_odm(macros) }
          vendor = message.vendor
        end
      end
      ack = odm.send_message(credentials(vendor), msg)
      message.sending!(nil, ack)
      logger.debug("Sent EmailMessage #{message.to_param} (account #{account.name}, admin #{message.user_id}) to ODM")
    end

    private

    def create_link_encoder(encoder)
      if encoder == 'ONE'
        return Java::ComGovdeliveryTmsTmsextended::LinkEncoder::ONE
      elsif encoder == 'TWO'
        return Java::ComGovdeliveryTmsTmsextended::LinkEncoder::TWO
      end
    end
  end
end
