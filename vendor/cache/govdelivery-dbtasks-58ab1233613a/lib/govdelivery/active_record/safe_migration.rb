module ActiveRecord
  module SafeMigration

    # Redefine common migration methods to be safer.

    # Indexes
    # Made adding and removing indices safe by default.

    def add_index(table_name, column_name, options = {})
      # If we're not in development or test, build the index ONLINE (It's not supported by XE VM)
      options.reverse_merge!(options: 'ONLINE') unless env.development? || env.test?
      super(table_name, column_name, options)
    rescue StandardError => error
      # Ignore error if the index already exists.
      raise error unless error.message.include? 'already exists'
      say "Skipping (#{error.message})", true
    end

    def remove_index(*args)
      super
    rescue StandardError => error
      # Ignore if the index doesn't exist.
      raise error unless error.message.include? 'does not exist'
      say "Skipping (#{error.message})", true
    end

    # Add column

    def add_column(*args)
      super
    rescue StandardError => error
      raise error unless error.message.include? 'ORA-01430'
      say "Skipping (#{error.message})", true
    end

    # Remove column

    def remove_column(table_name, column_name, type = nil, options = {})
      # Use the default implmentation when reverting an add_column.
      return super if reverting? || @direction == :down

      # When running post-release migrations, all running instances of the
      # application are running the new version of the code, which should be
      # igoring the column:
      say "You set `ignore_table_columns :#{column_name}` in the model corresponding to #{table_name}, right?"

      begin
        execute "ALTER TABLE #{table_name} SET UNUSED (#{column_name})"
      rescue StandardError => error
        raise error unless error.message.include? 'ORA-00904'
        say "Skipping (#{error.message}) since the column or table does not exist.", true
      end
    end

    # FK constraints

    def add_foreign_key(*)
      super
    rescue StandardError => error
      # Safely ignore "OCIError: ORA-02275: such a referential constraint already exists in the table"
      raise error unless error.message.include? 'ORA-02275'
      say "Skipping (#{error.message})", true
    end
  end

end
