module ActiveRecord
  module ConnectionAdapters
    if defined?(OracleEnhancedOCIConnection)
      class OracleEnhancedCurrentSchemaOCIConnection < OracleEnhancedOCIConnection
        # JDBCConnection holds onto config but OCIConnection doesn't
        def initialize(config)
          super
          @config = config
        end
      end
    end
  end
end