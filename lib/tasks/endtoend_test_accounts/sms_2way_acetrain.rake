require 'rake_helper'

namespace :test do

  desc 'Create an Account for testing SMS 2-Way ACEtrain'
  task :create_sms_2way_acetrain_test_account => :environment do |t|

    # Make sure the shared loopback vendors exist
    Rake::Task['db:create_shared_loopback_vendors'].invoke
    Rake::Task['db:create_shared_twilio_valid_test_vendor'].invoke

    # Create the SMS 2-Way Static Content test account
    a = create_test_account("SMS 2Way ACEtrain", shared_twilio_valid_test_vendors_config)

    # Set the transformer
    transformer_config = {
      content_type: 'application/json',
      transformer_class: 'etaspot'
    }

    transformer = a.transformers.find_by(content_type: transformer_config[:content_type])
    if transformer.nil?
      puts "Creating #{transformer_config[:content_type]} transformer with class #{transformer_config[:transformer_class]}"
      transformer = a.transformers.create(transformer_config)
    else
      puts "Account already has #{transformer_config[:content_type]} transformer"
      set_record_config(transformer, transformer_config)
      if transformer.changed?
        puts "Setting Transformer for #{transformer.content_type} to #{transformer.changes}"
        transformer.save!
      end
    end

    puts

  end # :create_sms_2way_acetrain_test_account

end # :db namespace
