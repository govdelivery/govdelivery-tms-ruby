require 'rails_helper'
RSpec.describe LoopbackEmailWorker, type: :worker do
  let(:loopback_vendor) { EmailVendor.create!(worker: 'LoopbackEmailWorker',
                                              name:   'test vendor') }
  let(:account) { create(:account, email_vendor: loopback_vendor) }
  let(:email_message) { create(:email_message, account: account) }

  subject { LoopbackEmailWorker.new }

  it 'should have a recipient with each status' do
    LoopbackEmailWorker.magic_addresses.each do |type, email|
      email_message.recipients.create!(email: email)
    end
    subject.perform("message_id" => email_message.id)
    LoopbackEmailWorker.magic_addresses.each do |type, email|
      expect(email_message.reload.recipients.where(status: type).count).to eq 1
    end
  end

end