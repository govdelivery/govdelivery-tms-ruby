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
    sms_message.ready! #recipients are processed
    subject.perform('message_id' => sms_message.id)
    LoopbackSmsWorker.magic_addresses.each do |type, _number|
      expect(sms_message.recipients.where(status: type).count).to eq 1
    end
  end

  it 'should get to sent state' do
    hooky = create(:webhook, account: account, event_type: 'sent', url: 'http://webhook.org')
    sms_message.recipients.create!(phone: LoopbackSmsWorker.magic_addresses[:sent])
    sms_message.ready! #recipients are processed
    Webhook.any_instance.expects(:invoke) #AASM properly calls webhook for sent transition
    subject.perform('message_id' => sms_message.id)

    expect(sms_message.recipients.where(status: :sent).count).to eq 1
    expect(sms_message.reload.status).to eq 'completed'
  end
end
