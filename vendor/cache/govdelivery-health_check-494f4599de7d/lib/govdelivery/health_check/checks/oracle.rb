module GovDelivery
  module HealthCheck
    module Checks
      class Oracle < Base
        QUERY = 'SELECT SYSDATE FROM DUAL'

        # error out if an exception is raised
        def check!
          pass! unless defined?(::ActiveRecord)  # don't do anything if no ActiveRecord

          ::ActiveRecord::Base.connection_pool.with_connection do |connection|
            connection.select_value(QUERY)
          end
        end
      end
    end
  end
end
