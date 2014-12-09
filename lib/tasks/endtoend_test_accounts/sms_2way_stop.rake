require 'rake_helper'

namespace :test do

  desc 'Create an Account for testing SMS 2-Way Stop'
  task :create_sms_2way_stop_test_account => :environment do |t|

    # Make sure the shared loopback vendors exist
    Rake::Task['db:create_shared_loopback_vendors'].invoke
    Rake::Task['db:create_shared_twilio_valid_test_vendor'].invoke

    # Create the SMS 2-Way Static Content test account
    a = create_test_account("SMS 2Way Stop", shared_twilio_valid_test_vendors_config)

    if !a.dcm_account_codes.include?(seed_dcm_account_id)
      puts "Adding DCM Account Code '#{seed_dcm_account_id}'"
      a.dcm_account_codes.add(seed_dcm_account_id)
      a.save!
    else
      puts "Found DCM Account Code '#{seed_dcm_account_id}'"
    end

    keyword = a.keywords.find_by_name('subscribe')
    if keyword.nil?
      puts "Creating default 'subscribe' keyword"
      keyword = a.keywords.build(name: 'subscribe', response_text: 'subscribe')
      keyword.save!
    else
      puts "Found 'subscribe' keyword"
    end

    command = keyword.commands.find_by_command_type(:dcm_subscribe)
    if command.nil?
      puts "Creating dcm_subscribe command for 'subscribe' keyword"
      command = keyword.commands.build(
        name: 'subscribe',
        command_type: :dcm_subscribe,
        params:{
          dcm_account_code: seed_dcm_account_id,
          dcm_topic_codes: seed_dcm_topic_codes
        })
      command.save!
    else
      puts "Found dcm_subscribe command for 'subscribe' keyword"
    end

  end # :create_sms_2way_stop_test_account

end # :db namespace
