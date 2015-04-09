require 'rake_helper'

namespace :test do
  desc 'Create an Account for testing SMS 2-Way BART'
  task create_sms_2way_bart_test_account: :environment do |_t|
    # Make sure the shared loopback vendors exist
    Rake::Task['db:create_shared_loopback_vendors'].invoke

    # Create the SMS 2-Way Static Content test account
    create_test_account('SMS 2Way BART', shared_loopback_vendors_config)

    puts
  end # :create_sms_2way_bart_test_account
end # :db namespace
