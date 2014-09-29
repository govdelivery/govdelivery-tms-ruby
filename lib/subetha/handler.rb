module Subetha
  class Handler
    java_import 'org.subethamail.smtp.RejectException'
    java_import 'org.apache.commons.io.IOUtils'
    java_import 'java.net.SocketTimeoutException'
    java_implements 'org.subethamail.smtp.MessageHandler'

    attr_accessor :message_context, :user, :message

    def initialize(ctx)
      self.message_context = ctx
    end
    
    def logger
      Rails.logger
    end

    def reject!(message)
      raise RejectException.new(530, message)
    end
    
    #/**
    #* Called first, after the MAIL FROM during a SMTP exchange.
    #*
    #* @param from is the sender as specified by the client.  It will
    #*  be a rfc822-compliant email address, already validated by
    #*  the server.
    #* @throws RejectException if the sender should be denied.
    #* @throws DropConnectionException if the connection should be dropped
    #*/
    java_signature 'void from(String from) throws RejectException'

    def from(from_string)
      reject!("Authentication required") unless message_context.authentication_handler
      if (self.user = User.includes(:account).for_token(message_context.authentication_handler.identity).first)
        reject!("Email service not available") unless user.account.feature_enabled?(:email)
      else
        reject!("Authentication required")
      end
      logger.debug("FROM #{from_string}")
    end

    #/**
    #* Called once for every RCPT TO during a SMTP exchange.
    #* This will occur after a from() call.
    #*
    #* @param recipient is a rfc822-compliant email address,
    #*  validated by the server.
    #* @throws RejectException if the recipient should be denied.
    #* @throws DropConnectionException if the connection should be dropped
    #*/
    java_signature 'void recipient(String recipient) throws RejectException'

    def recipient(recipient_string)
      logger.debug("RCPT TO #{recipient_string}")
    end

    #/**
    #* Called when the DATA part of the SMTP exchange begins.  This
    #* will occur after all recipient() calls are complete.
    #*
    #* Note: If you do not read all the data, it will be read for you
    #* after this method completes.
    #*
    #* @param data will be the smtp data stream, stripped of any extra '.' chars.  The
    #*                      data stream will be valid only for the duration of the call.
    #*
    #* @throws RejectException if at any point the data should be rejected.
    #* @throws DropConnectionException if the connection should be dropped
    #* @throws TooMuchDataException if the listener can't handle that much data.
    #*         An error will be reported to the client.
    #* @throws IOException if there is an IO error reading the input data.
    #*/
    java_signature 'void data(InputStream data) throws RejectException, TooMuchDataException, IOException'

    def data(input_stream)
      data                     = IOUtils.toString(input_stream)
      mail_message             = Mail.new(data)
      self.message                  = user.account.email_messages.build(body: mail_message.body.to_s, subject: mail_message.subject)
      self.message.async_recipients = mail_message.to.each.map { |rcpt| {email: rcpt} }
      if message.save_with_async_recipients
        CreateRecipientsWorker.perform_async({recipients: self.message.async_recipients,
                                              klass: self.message.class.name,
                                              message_id: self.message.id,
                                              send_options: self.send_options})
      else
        raise RejectException.new(421, "something went wrong: #{message.errors.full_messages}")
      end

    rescue SocketTimeoutException => e
      raise RejectException.new(421, e.message)
    ensure
      IOUtils.closeQuietly(input_stream)
    end

    #ripped from MessagesController
    def send_options
      routes              = Rails.application.routes.url_helpers
      opts                = {message_url: routes.twiml_url}
      opts[:callback_url] = routes.twilio_status_callbacks_url(:format => :xml) if Rails.configuration.public_callback
      opts
    end

    #/**
    #* Called after all other methods are completed.  Note that this method
    #* will be called even if the client never triggered any of the other callbacks.
    #*/
    java_signature 'void done()'

    def done
      logger.debug("DONE")
    end
  end
end
