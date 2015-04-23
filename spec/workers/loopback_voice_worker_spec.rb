require 'rails_helper'
RSpec.describe LoopbackVoiceWorker, type: :worker do
  let(:loopback_vendor) do
    VoiceVendor.create!(worker:   'LoopbackVoiceWorker',
                        name:     'test vendor',
                        username: 'sms_loopback_username',
                        password: 'dont care',
                        from:     '+15551112222')
  end
  let(:account) {create(:account, voice_vendor: loopback_vendor)}
  let(:voice_message) {create(:voice_message, account: account)}

  subject {LoopbackVoiceWorker.new}

  it 'should have a recipient with each status' do
    LoopbackVoiceWorker.magic_addresses.each do |_type, number|
      voice_message.recipients.create!(phone: number)
    end
    subject.perform('message_id' => voice_message.id)
    LoopbackVoiceWorker.magic_addresses.each do |type, _number|
      expect(voice_message.recipients.where(status: type).count).to eq 1
    end
  end
end
