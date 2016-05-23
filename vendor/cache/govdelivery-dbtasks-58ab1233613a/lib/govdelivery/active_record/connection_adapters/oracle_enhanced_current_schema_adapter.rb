module ActiveRecord
  module ConnectionAdapters
    class OracleEnhancedCurrentSchemaAdapter < OracleEnhancedAdapter
      #
      # All this stuff refers to current_user in the gem impl, but we want to use current_schema
      #

      def default_tablespace
        select_value("SELECT LOWER(default_tablespace) FROM user_users WHERE username = SYS_CONTEXT('userenv', 'current_schema')")
      end

      def tables(name = nil) #:nodoc:
        select_values(
          "SELECT DECODE(table_name, UPPER(table_name), LOWER(table_name), table_name) FROM all_tables WHERE owner = SYS_CONTEXT('userenv', 'current_schema') AND secondary = 'N'",
          name)
      end

      def materialized_views #:nodoc:
        select_values("SELECT LOWER(mview_name) FROM all_mviews WHERE owner = SYS_CONTEXT('userenv', 'current_schema')")
      end

      def temporary_table?(table_name) #:nodoc:
        select_value("SELECT temporary FROM all_tables WHERE owner = SYS_CONTEXT('userenv', 'current_schema') AND table_name = '#{table_name.upcase}'") == 'Y'
      end

      def initialize_schema_migrations_table
        if defined?(ActiveRecord::SchemaMigration) && ActiveRecord::SchemaMigration.respond_to?(:create_table)
          ActiveRecord::SchemaMigration.create_table
        else
          super
        end
      end

      # after creating table, grant CRUD permissions to roles that operational (app) user has
      def create_table(name, options = {})
        super.tap do
          grant_table_access_to_roles(name)
        end
      end

      def grant_table_access_to_roles(table_name)
        if @connection.different_schema_owner?
          plsql.connection = @connection.raw_connection
          %w{i d u}.each do |op|
            plsql.system.gd_grants('g', op, @connection.owner, table_name, "wo_#{@connection.owner}_all_role")
          end
          plsql.system.gd_grants('g', 's', @connection.owner, table_name, "ro_#{@connection.owner}_all_role")
        end
      end

      def grant_package_access_to_roles(package_name)
        if @connection.different_schema_owner?
          plsql.connection = @connection.raw_connection
          plsql.system.gd_grants('g', 'x', @connection.owner, package_name, "xo_#{@connection.owner}_all_role")
        end
      end

      def grant_sequence_access_to_roles(sequence_name)
        if @connection.different_schema_owner?
          plsql.connection = @connection.raw_connection
          plsql.system.gd_grants('g', 's', @connection.owner, sequence_name, "ro_#{@connection.owner}_all_role")
        end
      end

      # after creating sequence, grant read permission to role that operational (app) user has
      def create_sequence_and_trigger(table_name, options)
        super.tap do
          if @connection.different_schema_owner?
            grant_sequence_access_to_roles(options[:sequence_name] || default_sequence_name(table_name))
          end
        end
      end

      # returns the owner from the under
      def schema_owner
        oracle_enhanced_connection.owner
      end

      # returns the underlying OracleEnhancedCpnnection (JDBC or OCI)
      def oracle_enhanced_connection
        @connection
      end

    end
  end
end

