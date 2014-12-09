require 'rake_helper'

namespace :test do

  desc 'Create an Account for testing SMS 2-Way Subscribe'
  task :create_sms_2way_subscribe_test_account => :environment do |t|

    # Make sure the shared loopback vendors exist
    Rake::Task['db:create_shared_loopback_vendors'].invoke
    Rake::Task['db:create_shared_twilio_valid_test_vendor'].invoke

    # Create the SMS 2-Way Static Content test account
    a = create_test_account("SMS 2Way Subscribe", shared_twilio_valid_test_vendors_config)

    if !a.dcm_account_codes.include?(seed_dcm_account_id)
      puts "Adding DCM Account Code '#{seed_dcm_account_id}'"
      a.dcm_account_codes.add(seed_dcm_account_id)
      a.save!
    else
      puts "Found DCM Account Code '#{seed_dcm_account_id}'"
    end
  end # :create_sms_2way_subscribe_test_account

end # :db namespace
