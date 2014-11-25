require 'fileutils'
require 'rake_helper'

namespace :db do

  desc 'Create an Account for testing Webhooks'
  task :create_webhooks_test_account => :environment do |t|

    # Make sure the shared loopback vendors exist
    Rake::Task['db:create_shared_loopback_vendors'].invoke

    # Create the Webhooks test account
    create_test_account("Webhooks", shared_loopback_vendors_config)

  end # :create_webhooks_test_account

end # :db namespace
