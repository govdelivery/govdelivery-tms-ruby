require 'rake_helper'

namespace :e2e do
  desc 'Create an Account for end-to-end testing of sending email'
  task create_kahlo_endtoend: :environment do |_t|
    sms_vendor_name = 'Kahlo Loopback Sender'
    SmsVendor.find_or_initialize_by(name: sms_vendor_name).update_attributes!(
      worker:   'KahloMessageWorker',
      username: 'n/a',
      password: 'n/a',
      from:     '+15553665397')

    create_test_account('Kahlo Loopback End To End', {sms_vendor_name: sms_vendor_name})
  end
end
