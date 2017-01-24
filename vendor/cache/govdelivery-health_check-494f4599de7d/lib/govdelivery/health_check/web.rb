module GovDelivery
  module HealthCheck
    class Web
      include Router

      attr_writer :logger

      CONTENT_TYPE = { "Content-Type" => 'text/plain' }
      MAINTENANCE_STATUS = 503

      ##
      # Set variables used in root Rack handler for health checks.
      # These can be overridden at initialization time like this:
      #   GovDelivery::HealthCheck::Web.new(checks: [ GovDelivery::HealthCheck::Checks::RailsCache ])
      #
      # opts:
      #   happy_text:       what to print if the app seems fine
      #   maintenance_text: what to print if the application is down for maintenance
      #   maintfile:        file to check to see if node is down for maintenance
      #   checks:           the actual checks to be run

      set :happy_text, "200 totally OK"
      set :maintenance_text, "down for maintenance"
      set :maintfile, "/var/run/maintenance.lock"
      set :checks, [ Checks::RailsCache, Checks::Sidekiq, Checks::Oracle ]

      # This gets run before every route
      before_route { [MAINTENANCE_STATUS, CONTENT_TYPE, [maintenance_text]] if maintenance? }

      route "/" do
        responses = checks.map {|check| check.new(params).do_check }

        status = responses.max { |a, b| a.status <=> b.status }.status
        response_text = responses.map(&:message).compact.join(", ")
        response_text = if status >= 400
          response_text
        else
          response_text.empty? ? happy_text : "#{happy_text} - #{response_text}"
        end

        [status, CONTENT_TYPE, [response_text]]
      end

      # Add additional routes with route "/path" syntax

      def maintenance?
        File.exists?(maintfile)
      end

      def logger
        @logger ||= (sidekiq_logger || rails_logger || default_logger)
      end

      private

      def sidekiq_logger
        Sidekiq.logger if defined?(Sidekiq)
      end

      def rails_logger
        Rails.logger if defined?(Rails)
      end

      def default_logger
        Logger.new(STDOUT)
      end
    end
  end
end
