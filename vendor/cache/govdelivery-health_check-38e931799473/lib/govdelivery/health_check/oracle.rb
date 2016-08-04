module GovDelivery
  module HealthCheck
    class Oracle
      include Singleton
      QUERY = 'SELECT SYSDATE FROM DUAL'

      def check!
        return unless defined?(::ActiveRecord)
        ::ActiveRecord::Base.connection_pool.with_connection do |connection|
          connection.select_value(QUERY)
        end
      end
    end
  end

end