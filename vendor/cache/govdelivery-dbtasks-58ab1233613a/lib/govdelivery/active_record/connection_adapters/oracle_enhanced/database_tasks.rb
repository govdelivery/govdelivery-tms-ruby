module ActiveRecord
  module ConnectionAdapters
    class OracleEnhancedAdapter
      class DatabaseTasks

        # This DatabaseTasks class provided by the OracleEnhancedAdapter
        # simply delegated it's connection methods to ActiveRecord::Base.
        # So all that needs to be done is to re-delegate to ActiveRecord::Migration.
        delegate :connection, :establish_connection, to: ActiveRecord::Migration

      end
    end
  end
end
