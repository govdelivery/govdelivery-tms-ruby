module ActiveRecord
  class Migration #:nodoc:
    include SafeMigration

    cattr_accessor :env do
      defined?(Rails) ? Rails.env : nil
    end

    def self.establish_connection(spec = nil)
      # Re-establish a connection with the given connection spec.
      spec ||= env.try(:to_sym)
      resolver = ConnectionAdapters::ConnectionSpecification::Resolver.new(ActiveRecord::Base.configurations)
      spec = resolver.spec(spec)
      spec.config[:username] = spec.config[:migration_username] if spec.config[:migration_username]
      spec.config[:password] = spec.config[:migration_password] if spec.config[:migration_password]
      @connection_pool.disconnect! if @connection_pool
      @connection_pool = ActiveRecord::ConnectionAdapters::ConnectionPool.new(spec)
    end

    def self.connection_pool
      @connection_pool ||= establish_connection
    end

    # This method was copied from Rails.  The only change is that it
    # uses ActiveRecord::Migration.connection instead of ActiveRecord::Base.connection
    def connection
      @connection || ActiveRecord::Migration.connection_pool.connection
    end

    # This method was copied from Rails.  The only change is that it
    # uses ActiveRecord::Migration.connection_pool instead of ActiveRecord::Base.connection_pool
    def migrate(direction)
      return unless respond_to?(direction)

      case direction
      when :up   then announce "migrating"
      when :down then announce "reverting"
      end

      time   = nil
      ActiveRecord::Migration.connection_pool.with_connection do |conn|
        time = Benchmark.measure do
          exec_migration(conn, direction)
        end
      end

      case direction
      when :up   then announce "migrated (%.4fs)" % time.real; write
      when :down then announce "reverted (%.4fs)" % time.real; write
      end
    end
  end
end
