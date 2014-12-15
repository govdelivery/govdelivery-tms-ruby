require 'rake_helper'

namespace :test do

  desc 'Create an Account for testing SMS 2-Way CDC'
  task :create_sms_2way_cdc_test_account => :environment do |t|

    # Make sure the shared loopback vendors exist
    Rake::Task['db:create_shared_loopback_vendors'].invoke
    Rake::Task['db:create_shared_twilio_valid_test_vendor'].invoke

    # Create the SMS 2-Way Static Content test account
    a = create_test_account("SMS 2Way CDC", shared_twilio_valid_test_vendors_config)
  end # :create_sms_2way_cdc_test_account

end # :db namespace
