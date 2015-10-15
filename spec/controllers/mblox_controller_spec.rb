require 'rails_helper'

describe MbloxController do
  let(:vendor) {create(:sms_vendor, worker: 'Mblox::SenderWorker')}
  let(:account) {create(:account, sms_vendor: vendor, name: 'name')}
  let(:user) {account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop')}
  let(:message) {user.sms_messages.create(body: 'A' * 160)}

  before do
    3.times do |i|
      message.recipients.create(phone: (6_125_551_200 + i).to_s).tap do |m|
        m.ack!("1")
      end
    end
  end

  context '#report' do
    it 'should return 404 on a non-existant Recipient' do
      post :report, batch_id: "2", recipient: "+161255512001", status: "Delivered"
      expect(response.response_code).to eq(404)
    end

    it 'should return find a recipient by batch id and phone number' do
      post :report, batch_id: "1", recipient: "+16125551201", status: "Delivered"
      expect(response.response_code).to eq(201)
      expect(assigns(:recipient).id).not_to be_nil
    end
  end

  context "status maps" do
    it 'should raise an error if no matching status is found' do
      expect { post :report, batch_id: "1", recipient: "+16125551201" }.to raise_error(StandardError)
    end

    it 'should noop if status is Queued' do
      post :report, batch_id: "1", recipient: "+16125551201", status: "Queued"
      expect(assigns(:recipient)).to be_nil
    end

    it 'should noop if status is Dispatched' do
      post :report, batch_id: "1", recipient: "+16125551201", status: "Dispatched"
      expect(assigns(:recipient)).to be_nil
    end

    it 'should retry if status is Expired' do
      SmsRecipient.any_instance.expects(:retry!)
      post :report, batch_id: "1", recipient: "+16125551201", status: "Expired"
      expect(assigns(:recipient)).not_to be_nil
    end

    it 'should retry if status is Aborted but the secondary status is temporary', blah: true do
      SmsRecipient.any_instance.expects(:retry!)
      post :report, batch_id: "1", recipient: "+16125551201", status: "Aborted", code: 402
      expect(assigns(:recipient)).not_to be_nil
    end

    it 'should cancel if status is Aborted but the secondary status is permanent' do
      post :report, batch_id: "1", recipient: "+16125551201", status: "Aborted"
      expect(assigns(:recipient)).not_to be_nil
      recipient = assigns(:recipient)
      expect(recipient.status).to eq("canceled")
    end

    it 'should mark as sent if status is Delivered' do
      post :report, batch_id: "1", recipient: "+16125551201", status: "Delivered"
      expect(assigns(:recipient)).not_to be_nil
      recipient = assigns(:recipient)
      expect(recipient.status).to eq("sent")
    end

    it 'should mark as failed if status is Failed' do
      post :report, batch_id: "1", recipient: "+16125551201", status: "Failed"
      expect(assigns(:recipient)).not_to be_nil
      recipient = assigns(:recipient)
      expect(recipient.status).to eq("failed")
    end

    it 'should mark as failed if status is Rejected' do
      post :report, batch_id: "1", recipient: "+16125551201", status: "Rejected"
      expect(assigns(:recipient)).not_to be_nil
      recipient = assigns(:recipient)
      expect(recipient.status).to eq("failed")
    end

    it 'should mark as inconclusive if status is Unknown' do
      post :report, batch_id: "1", recipient: "+16125551201", status: "Unknown"
      expect(assigns(:recipient)).not_to be_nil
      recipient = assigns(:recipient)
      expect(recipient.status).to eq("inconclusive")
    end
  end
end
