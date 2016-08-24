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
        @logger     = opts[:logger]
      end

      def call(env)
        if stopping?
          return [307, HEADERS, ["shutting down"]]
        elsif maintenance?
          return [503, HEADERS, ["down for maintenance"]]
        end

        begin
          checks.map do |check|
            begin
              check.instance.check!
              [200, HEADERS, [@happy_text]]
            rescue Warning => e
              # Some F5 checks look explicitly for the happy_text
              [429, HEADERS, ["#{@happy_text} - #{e.message}"]]
            rescue => e
              [500, HEADERS, [e.message]]
            end
          end.sort { |a, b| b<=> a }.first
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