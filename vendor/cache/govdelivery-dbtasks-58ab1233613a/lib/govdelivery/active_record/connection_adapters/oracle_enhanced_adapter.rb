# this redefines a module from oracle_enhanced_adapter.rb in the oracle-enhanced gem

module ActiveRecord
  module ConnectionHandling #:nodoc:
    # Establishes a connection to the database that's used by all Active Record objects.
    def oracle_enhanced_connection(config) #:nodoc:
      if config[:emulate_oracle_adapter] == true
        raise "can't emulate OracleAdapter"
      else
        # return an instance of our OracleEnhancedAdapter subclass
        ConnectionAdapters::OracleEnhancedCurrentSchemaAdapter.new(
          # this is a different factory-ish method than the default
          ConnectionAdapters::OracleEnhancedConnection.get_connection(config), logger, config)
      end
    end
  end
end

