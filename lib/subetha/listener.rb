require 'celluloid'

module Subetha
  PORT = 2525

  java_import 'org.subethamail.smtp.server.SMTPServer'
  java_import 'org.subethamail.smtp.auth.EasyAuthenticationHandlerFactory'
  java_import 'org.apache.commons.io.IOUtils'
  java_import 'org.subethamail.smtp.auth.LoginFailedException'

  class Listener
    include Celluloid
    attr_accessor :config, :server
    finalizer :stop

    def initialize(config)
      @config = defaults.merge!(config)
    end

    def run
      server.port                           = PORT
      server.authentication_handler_factory =
        org.subethamail.smtp.auth.EasyAuthenticationHandlerFactory.new do |email, password|
          begin
            raise 'nope' unless User.with_token(password).present?
          rescue Java::java::lang::Throwable, StandardError => e
            Sidekiq.logger.info "failed to authenticate user #{email}"
            raise LoginFailedException.new
          end
        end
      #@server.require_auth = true
      server.start
    end

    def stop
      server.try(:stop)
    end

    def server
      return @server if @server
      @server = SMTPServer.new do |message_context|
        Handler.new(message_context)
      end
      config.each do |attr, val|
        server.send("#{attr}=", val)
      end
      @server
    end

    def defaults
      {
        port:             2525,
        software_name:    "GovDelivery TMS",
        max_connections:  100,
        max_recipients:   500,
        max_message_size: 10_000_000,
        host_name:        "#{Rails.env.production? ? '' : "#{Rails.env.to_s}-"}tms.govdelivery.com"
      }
    end

  end
end



