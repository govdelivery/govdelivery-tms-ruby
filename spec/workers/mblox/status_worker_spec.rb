require 'rails_helper'

describe Mblox::StatusWorker do
  let(:vendor) { create(:sms_vendor, worker: 'Mblox::SenderWorker') }
  let(:account) { create(:account, sms_vendor: vendor, name: 'name') }
  let(:user) { account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop') }
  let(:message) { user.sms_messages.create(body: 'A' * 160) }

  subject { Mblox::StatusWorker.new }

  before do
    3.times do |i|
      message.recipients.create(phone: (6_125_551_200 + i).to_s).tap do |m|
        m.ack!("1")
      end
    end
  end

  context '#report' do
    it 'should return 404 on a non-existant Recipient' do
      expect{ subject.perform({batch_id: "2", recipient: "+161255512001", status: "Delivered"}.stringify_keys)}.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'should return find a recipient by batch id and phone number' do
      subject.perform({batch_id: "1", recipient: "+16125551201", status: "Delivered"}.stringify_keys)
      expect(subject.recipient).not_to be_nil
    end
  end

  context "status maps" do
    it 'should raise an error if no matching status is found' do
      expect {subject.perform({batch_id: "1", recipient: "+16125551201"}.stringify_keys)}.to raise_error(StandardError)
    end

    it 'should noop if status is Queued' do
      subject.perform({batch_id: "1", recipient: "+16125551201", status: "Queued"}.stringify_keys)
    end

    it 'should noop if status is Dispatched' do
      subject.perform({batch_id: "1", recipient: "+16125551201", status: "Dispatched"}.stringify_keys)
    end

    it 'should retry if status is Expired' do
      SmsRecipient.any_instance.expects(:retry!)
      subject.perform({batch_id: "1", recipient: "+16125551201", status: "Expired"}.stringify_keys)
    end

    it 'should retry if status is Aborted but the secondary status is temporary', blah: true do
      SmsRecipient.any_instance.expects(:retry!)
      subject.perform({batch_id: "1", recipient: "+16125551201", status: "Aborted", code: '402'}.stringify_keys)
    end

    it 'should cancel if status is Aborted but the secondary status is permanent' do
      subject.perform({batch_id: "1", recipient: "+16125551201", status: "Aborted"}.stringify_keys)
      expect(subject.recipient.status).to eq("canceled")
    end

    it 'should mark as sent if status is Delivered' do
      subject.perform({batch_id: "1", recipient: "+16125551201", status: "Delivered"}.stringify_keys)
      expect(subject.recipient.status).to eq("sent")
    end

    it 'should mark as failed if status is Failed' do
      subject.perform({batch_id: "1", recipient: "+16125551201", status: "Failed"}.stringify_keys)
      expect(subject.recipient.status).to eq("failed")
    end

    it 'should mark as failed if status is Rejected' do
      subject.perform({batch_id: "1", recipient: "+16125551201", status: "Rejected"}.stringify_keys)
      expect(subject.recipient.status).to eq("failed")
    end

    it 'should mark as inconclusive if status is Unknown' do
      subject.perform({batch_id: "1", recipient: "+16125551201", status: "Unknown"}.stringify_keys)
      expect(subject.recipient.status).to eq("inconclusive")
    end

    it 'should not blow up when sent "perform_async"' do
      Mblox::StatusWorker.perform_async
    end
  end

end
