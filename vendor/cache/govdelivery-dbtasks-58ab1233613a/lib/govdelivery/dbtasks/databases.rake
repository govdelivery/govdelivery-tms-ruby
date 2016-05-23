namespace :db do

  # Disable some tasks entirely or for specific environments.

  task :disabled_for_safety! do
    raise 'This task has been disabled for safety.'
  end

  task :require_dev_or_test! do
    raise 'This task requires development and test environment!' unless Rails.env.development? || Rails.env.test?
  end

  namespace :create do
    task :all => :disabled_for_safety!
  end
  Rake::Task['db:create'].clear if Rake::Task.task_defined?('db:create')
  task :create do
    puts 'Database is created by Oracle VM.  Application does not have permission to create database.'
  end

  namespace :drop do
    task :all => :disabled_for_safety!
  end
  task :drop => :require_dev_or_test!

  namespace :purge do
    task :all => :disabled_for_safety!
  end
  task :purge => :require_dev_or_test!

end
