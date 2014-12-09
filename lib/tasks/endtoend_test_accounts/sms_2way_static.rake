require 'rake_helper'

namespace :test do

  desc 'Create an Account for testing SMS 2-Way with Static Content'
  task :create_sms_2way_static_test_account => :environment do |t|

    # Make sure the shared loopback vendors exist
    Rake::Task['db:create_shared_loopback_vendors'].invoke

    # Create the SMS 2-Way Static Content test account
    create_test_account("SMS 2Way Static", shared_loopback_vendors_config)

  end # :create_sms_2way_static_test_account

end # :db namespace
