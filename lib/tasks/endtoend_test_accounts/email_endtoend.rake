require 'rake_helper'

namespace :test do
  desc 'Create an Account for end-to-end testing of sending email'
  task create_email_endtoend_test_account: :environment do |_t|
    # Make sure the shared loopback vendors exist
    Rake::Task['db:create_shared_loopback_vendors'].invoke

    # Create the SMS 2-Way Static Content test account
    create_test_account('Email End To End', shared_live_email_vendors_config)
  end # :create_email_endtoend_test_account
end # :db namespace
