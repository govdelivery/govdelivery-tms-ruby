require 'rails_helper'
RSpec.describe LoopbackEmailWorker, type: :worker do
  let(:loopback_vendor) do
    EmailVendor.create!(worker: 'LoopbackEmailWorker',
                        name:   'test vendor')
  end
  let(:account) {create(:account, email_vendor: loopback_vendor)}
  let(:email_message) {create(:email_message, account: account)}

  subject {LoopbackEmailWorker.new}

  it 'should have a recipient with each status' do
    LoopbackEmailWorker.magic_addresses.each do |_type, email|
      email_message.recipients.create!(email: email)
    end
    subject.perform('message_id' => email_message.id)

    state_map = LoopbackEmailWorker.magic_addresses.each_with_object({}) { |(k,v), h| h[k] = k }
    state_map[:bounced] = :failed
    state_map[:opened] = :sent
    state_count = state_map.values.each_with_object({}) {|state, h| h[state] = 1}
    state_count[:failed] = 2
    state_count[:sent] = 2

    LoopbackEmailWorker.magic_addresses.each do |type, _email|
      expect(email_message.reload.recipients.where(status: state_map[type]).count).to eq state_count[state_map[type]]
    end
  end
end
