module ActiveRecord
  module ConnectionAdapters
    module CurrentSchemaSupport #:nodoc:
      extend ActiveSupport::Concern

      included do
        attr_reader :raw_connection, :config
        attr_accessor :owner, :username
      end

      module ClassMethods #:nodoc:
        # this is basically OracleEnhancedConnection.create
        # except it returns our subclassed OCIConnection (MRI only)
        # and calls after_initialize
        def get_connection(config)
          conn = case ORACLE_ENHANCED_CONNECTION
            when :oci
              OracleEnhancedCurrentSchemaOCIConnection.new(config)
            when :jdbc
              OracleEnhancedJDBCConnection.new(config)
            else
              nil
          end.tap(&:after_initialize)
        end
      end

      # owner is set to the db user when connection is created
      # based on :schema or :test_schema
      def after_initialize
        if schema = config[:schema]
          self.username = config[:username].upcase
          self.owner    = schema.upcase
          exec "alter session set current_schema = #{schema}" if OracleEnhancedAdapter::VERSION < '1.6.0'
        else
          warn "WARNING: No :schema specified in database.yml"
          self.username = self.owner.upcase
        end
      end

      def different_schema_owner?
        username != owner
      end
    end

    class OracleEnhancedConnection #:nodoc:
      include CurrentSchemaSupport
    end
  end
end
