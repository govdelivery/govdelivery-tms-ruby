module ActiveRecord
  module Tasks
    module DatabaseTasks
      extend self

      # The vanilla version of this method in Rails establishes a connection using ActiveRecord::Base.
      def load_schema_for(configuration, format = ActiveRecord::Base.schema_format, file = nil) # :nodoc:
        file ||= schema_file(format)
        case format
        when :ruby
          check_schema_file(file)
          ActiveRecord::Migration.establish_connection(configuration)
          ActiveRecord::Base.establish_connection(configuration)
          load(file)
        when :sql
          check_schema_file(file)
          structure_load(configuration, file)
        else
          raise ArgumentError, "unknown format #{format.inspect}"
        end
      end

    end
  end
end
