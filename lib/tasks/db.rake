namespace :db do
  # Stop-gap measures to prevent people from doing bad things to a database
  namespace :create do
    redefine_task :all do
      raise "This task has been disabled for safety."
    end
  end

  namespace :drop do
    redefine_task :all do
      raise "This task has been disabled for safety."
    end
  end

  # Creating a local db requires a password and doesn't work with our Oracle VM setup.
  # Just redefine the the task to do nothing.
  redefine_task :create do
    puts 'Database is created by Oracle VM.  Application does not have permission to create database.'
  end

  # Similarly, our app user doesn't have the permission to drop the schema.
  # Instead, purge it of everything to make it empty.
  desc "Drop everything in the defined schema, including tables, sequences, views, procedures, packages, functions, triggers, types, and synonyms"
  redefine_task drop: [:environment, :load_config] do
    # 'structure_drop: db_stored_code' in database.yml will supress 'drop table' statements (except for temp tables)
    raise 'db:drop is only for development and test environments!' unless Rails.env.development? || Rails.env.test?
    # Purge/Disable the recycling bin.
    ActiveRecord::Base.connection.execute('purge recyclebin')
    ActiveRecord::Base.connection.execute('alter session set recyclebin = off')
    drop_sql = ActiveRecord::Base.connection.full_drop(false)
    drop_sql.split(/\n*\/\n*/).each do |ddl|
      ddl.chop! if ddl.last == ";"
      ActiveRecord::Base.connection.execute(ddl) unless ddl.blank?
    end
  end
end
