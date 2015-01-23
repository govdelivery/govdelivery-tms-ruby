require 'rake_helper'

namespace :test do

  desc 'Create an Account for testing SMS 2-Way ACEtrain'
  task :create_sms_2way_acetrain_test_account => :environment do |t|

    # Make sure the shared loopback vendors exist
    Rake::Task['db:create_shared_loopback_vendors'].invoke
    Rake::Task['db:create_shared_twilio_valid_test_vendor'].invoke

    # Create the SMS 2-Way Static Content test account
    create_test_account("SMS 2Way ACEtrain", shared_twilio_valid_test_vendors_config)
    puts

  end # :create_sms_2way_acetrain_test_account

end # :db namespace
