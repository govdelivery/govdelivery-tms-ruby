require 'rails_helper'
RSpec.describe LoopbackSmsWorker, type: :worker do
  let(:loopback_vendor) do
    SmsVendor.create!(worker:   'LoopbackSmsWorker',
                      name:     'test vendor',
                      username: 'sms_loopback_username',
                      password: 'dont care',
                      from:     '+15551112222')
  end
  let(:account) {create(:account, sms_vendor: loopback_vendor)}
  let(:sms_message) {create(:sms_message, account: account, sms_vendor: loopback_vendor)}

  subject {LoopbackSmsWorker.new}

  it 'should have a recipient with each status' do
    LoopbackSmsWorker.magic_addresses.each do |_type, number|
      sms_message.recipients.create!(phone: number)
    end
    subject.perform('message_id' => sms_message.id)
    LoopbackSmsWorker.magic_addresses.each do |type, _number|
      expect(sms_message.recipients.where(status: type).count).to eq 1
    end
  end
end
