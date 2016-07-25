module GovDelivery
  module HealthCheck
    class Web
      attr_accessor :logger, :stopfile, :maintfile, :checks
      attr_writer :stopping, :maintenance


      HEADERS = {"Content-Type" => 'text/plain'}

      ##
      # Creates a new Rack handler for health checks
      #
      # opts:
      #   happy_text:  what to print if the app seems fine
      #   stopfile:    file to check to see if service is about to stop
      #   maintfile:   file to check to see if node is down for maintenance

      def initialize(opts={})
        @happy_text = opts[:happy_text] || "200 totally OK"
        @stopfile   = opts[:stopfile] || "/var/run/service-stop.lock"
        @maintfile  = opts[:maintfile] || "/var/run/maintenance.lock"
      end

      def call(env)
        if stopping?
          return [307, HEADERS, ["shutting down"]]
        elsif maintenance?
          return [503, HEADERS, ["down for maintenance"]]
        end

        begin
          checks.each do |check|
            check.instance.check!
          end

          [200, HEADERS, [@happy_text]]
        rescue Warning => e
          [429, HEADERS, [e.message]]
        rescue => e
          [500, HEADERS, [e.message]]
        end

      end

      def stopping?
        File.exists?(stopfile)
      end

      def maintenance?
        File.exists?(maintfile)
      end

      def checks
        @checks ||= [RailsCache, Sidekiq, Oracle]
      end

      protected

      def check_oracle

      end

      def check_redis(sysdate)


      end

      def logger
        @logger ||= if defined?(Sidekiq)
                      Sidekiq.logger
                    elsif defined(Rails)
                      Rails.logger
                    else
                      Logger.new(STDOUT)
                    end
      end
    end

  end
end