require 'rails_helper'

describe Kahlo::StatusWorker do
  let(:vendor) { create(:sms_vendor, worker: 'KahloMessageWorker') }
  let(:account) { create(:account, sms_vendor: vendor, name: 'name') }
  let(:user) { account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop') }
  let(:message) { user.sms_messages.create(body: 'A' * 160) }
  let(:recipient) { message.recipients.first }

  subject { Kahlo::StatusWorker.new }

  before do
    3.times do |i|
      message.recipients.create(phone: (6_125_551_200 + i).to_s).tap do |m|
        m.sending!("kahlo")
      end
    end
  end

  it 'should fail forever on nonexistent recipient' do
    expect { subject.perform({callback_id: "NOPE", status: "unimportant"}.stringify_keys) }.to raise_error(Sidekiq::Retries::Fail)
  end

  context "status maps" do
    it 'should raise an error if no matching status is found' do
      expect { subject.perform({callback_id: recipient.id, status: 'none'}.stringify_keys) }.to raise_error(Sidekiq::Retries::Fail)
    end

    %W{new enqueued attempted}.each do |status|
      it "should noop if status is #{status}" do
        subject.perform({callback_id: recipient.id, status: status}.stringify_keys)
        expect(subject.recipient.sending?).to be true
      end
    end

    it "should fail if status is failed" do
      subject.perform({callback_id: recipient.id, status: 'failed', status_message: 'is bad'}.stringify_keys)
      expect(subject.recipient.failed?).to be true
      expect(subject.recipient.error_message).to eq 'is bad'
    end

    %W{vendor_sent carrier_delivered}.each do |status|
      it "should be sent if status is #{status}" do
        subject.perform({callback_id: recipient.id, status: status}.stringify_keys)
        expect(subject.recipient.sent?).to be true
      end
    end
  end

end
