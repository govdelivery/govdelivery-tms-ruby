module GovDelivery
  module HealthCheck
    module Checks
      class Base
        PASS_STATUS = 200
        WARN_STATUS = 202
        FATAL_STATUS = 518
        ERROR_STATUS = 500

        attr_reader :params

        # Each check can be parameterized -- these are passed down from Rack
        def initialize(params)
          @params = params
        end

        # The entry point for all of our checks, this method should call one of the
        # following methods:
        #   - pass! (noop!): The check passed, no issue
        #   - warn!:         The check failed, but won't cause the node to be marked as erroring.
        #                    This is useful predominantly for checking background services that don't
        #                    necessarily indicate web-node health.
        #   - fatal!:        The check failed, return a node error so that the web node can be marked down
        #
        # If execution succeeds and none of these are called, the check is automatically considered a pass.
        def check!
          raise NotImplemented.new("Implement the check! method on your subclass!")
        end

        def do_check
          catch(:stop) { check!; pass! }
        rescue StandardError => e
          Response.new(ERROR_STATUS, e.message)
        end

        def pass!
          throw :stop, Response.new(PASS_STATUS)
        end
        alias_method :noop!, :pass!

        def warn!(message)
          throw :stop, Response.new(WARN_STATUS, message)
        end

        def fatal!(message)
          throw :stop, Response.new(FATAL_STATUS, message)
        end
      end

      class Response
        attr_reader :message, :status

        def initialize(status, message = nil)
          @status = status
          @message = message
        end
      end
    end
  end
end
