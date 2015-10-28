require 'base'

module Odm
  class TmsExtendedSenderWorker < Odm::TmsExtendedWorker
    sidekiq_options retry:             10,
                    queue:             :sender,
                    dynamic_queue_key: ->(args) {args['subject'].try(:parameterize)}

    def perform(options)
      super {deliver(options['message_id'])}
    end

    def deliver(message_id)
      message, vendor, account, creds, macros = nil
      msg = ExtendedMessage.new

      # This block reduces the window of time that we need an AR connection
      # so that the ODM send is not coupled with the database queries.
      ActiveRecord::Base.connection_pool.with_connection do
        message = EmailMessage.includes(:account).find(message_id)
        raise "#{message.class.name} #{message.id} is not ready for delivery!" unless message.queued?
        vendor  = message.vendor
        macros  = message.macros
        account = message.account
        message.recipients.find_each { |recipient| msg.to << recipient.to_odm(macros)}
      end
      
      creds = credentials(vendor)

      # There is no need to finish this method if this message is already in ODM.  This
      # could hit the remote endpoint, which is why it is outside of the database
      # access block.
      if extended_message_exists?(creds, message.id)
        logger.info("Skipped sending EmailMessage #{message.to_param} (account #{account.name}, " +
                    "admin #{message.user_id}) to ODM because it exists")
        return

      # This is not a retry and/or the message doesn't exist in ODM yet
      else

        # There should be no database access in the next section
        logger.debug("Building extended message...")
        msg.subject             = message.to_odm(:subject)
        msg.body                = message.to_odm(:body)
        msg.from_name           = message.from_name || ''
        msg.from_email          = message.from_email
        msg.errors_to_email     = message.errors_to
        msg.reply_to_email      = message.reply_to
        msg.email_column        = 'email'
        msg.recipient_id_column = 'recipient_id'
        msg.headers << odm_header('X-TMS-Recipient', '##x_tms_recipient##')
        msg.record_designator   = message.odm_record_designator
        msg.track_clicks        = message.click_tracking_enabled?
        msg.track_opens         = message.open_tracking_enabled?
        msg.link_encoder        = create_link_encoder(account.link_encoder)
        msg.message_id          = message.id.to_s

        # Hit the remote SOAP endpoint.  Definitely don't want this inside a database access block.
        logger.debug("Sending extended message to ODM...")
        ack = odm.send_message(creds, msg)
        logger.debug("Done sending extended message to ODM.")

        # Here again we are performing database access, which is why we need to trap 
        # the timeout error.
        begin
          self.class.mark_sending(message, ack)
        rescue ActiveRecord::ConnectionTimeoutError
          self.class.delay(retry: 10).mark_sending(message.id, ack)
        end
        logger.debug("Sent EmailMessage #{message.to_param} (account #{account.name}, admin #{message.user_id}) to ODM")
      end
    end

    def self.mark_sending(message_or_id, ack)
      message_or_id = EmailMessage.find(message_or_id) unless message_or_id.is_a?(EmailMessage)
      message_or_id.sending!(ack)
    end

    ##
    # Sometimes ODM receives an XACT message OK but closes
    # the socket before XACT can read the response.  When XACT tries to read the SOAP response, it 
    # fails with a connection reset error and assumes the message did not get sent - 
    # whereupon it starts retrying the message.  
    #
    # This prevents the cycle from continuing by checking if we already sent this message. 
    # We can do this because we previously passed the message id to ODM when we 
    # sent it the first time.
    #
    # The first time we send a message, we assume that it hasn't been 
    # sent already to save a trip over the wire.
    #
    def extended_message_exists?(creds, message_id)
      return false unless retrying?
      odm.extended_message_exists?(creds, message_id.to_s)
    end

    private

    def odm_header(name, value)
      h       = Header.new
      h.name  = name
      h.value = value
      h
    end

    def create_link_encoder(encoder)
      if encoder == 'ONE'
        return Java::ComGovdeliveryTmsTmsextended::LinkEncoder::ONE
      elsif encoder == 'TWO'
        return Java::ComGovdeliveryTmsTmsextended::LinkEncoder::TWO
      end
    end
  end
end
