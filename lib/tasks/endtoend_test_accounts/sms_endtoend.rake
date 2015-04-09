require 'rake_helper'

namespace :test do
  desc 'Create an Account for testing SMS End-to-End'
  task create_sms_endtoend_test_account: :environment do |_t|
    # Make sure the shared loopback vendors exist
    Rake::Task['db:create_shared_loopback_vendors'].invoke
    Rake::Task['db:create_shared_live_phone_vendors'].invoke

    # Create the SMS End-to-End test account
    create_test_account('SMS End To End', shared_live_phone_vendors_config)
  end # :create_sms_endtoend_test_account
end # :db namespace
