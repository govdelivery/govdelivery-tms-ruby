namespace :db do
  namespace :migrate do
    desc  ['db:structure:drop', 'db:migrate'].join(', ')
    task :full_rebuild => ['db:structure:drop', 'db:migrate'] do

    end
  end
  namespace :structure do
    desc "Drop everything in the defined schema, including tables, sequences, views, procedures, packages, functions, triggers, types, and synonyms"
    task :drop => :environment do
      drop_sql = ActiveRecord::Base.connection.full_drop(false)
      drop_sql.split(/\n*\/\n*/).each do |ddl|
        ddl.chop! if ddl.last == ";"
        unless ddl.blank?
          puts ddl
          ActiveRecord::Base.connection.execute(ddl)
        end
      end
    end
  end
end