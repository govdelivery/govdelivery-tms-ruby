require 'rails_helper'
require File.expand_path('../../../../app/workers/base', __FILE__)

describe Mblox::SenderWorker do
  let (:response) { {status: 401} }
  let (:retryable_error) { Brick::Errors::ClientError.new(response) }
  let (:nonretryable_error) { Brick::Errors::ClientError.new({status: "blah"}) }

  let(:vendor) {create(:sms_vendor, worker: 'Mblox::SenderWorker')}
  let(:account) {create(:account, sms_vendor: vendor, name: 'name')}
  let(:user) {account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop')}
  let(:message) {user.sms_messages.create(body: 'A' * 160)}
  let(:recipient) {message.recipients.create(phone: "8181112222")}
  let(:client) {mock('brick_client')}

  context 'a send that raises a retryable exception' do
    it 'should retry when there\'s a client error' do
      Brick.expects(:new).returns(client)
      client.expects(:create_batch).raises(retryable_error)
      expect { subject.perform(recipient_id: recipient.id, message_id: message.id) }.to raise_error(Sidekiq::Retries::Retry)
    end

    it 'should retry when there\'s a random error' do
      Brick.expects(:new).returns(client)
      client.expects(:create_batch).raises(StandardError.new)
      expect { subject.perform(recipient_id: recipient.id, message_id: message.id) }.to raise_error(Sidekiq::Retries::Retry)
    end
  end

  context 'a send that raises a nonretryable exception' do
    it 'should not retry when there\'s a client error' do
      Brick.expects(:new).returns(client)
      client.expects(:create_batch).raises(nonretryable_error)
      SmsRecipient.any_instance.expects(:failed!)
      expect { subject.perform(recipient_id: recipient.id, message_id: message.id) }.not_to raise_error
    end
  end

  context 'a successful send' do
    it 'should mark the recipient as sending' do
      Brick.expects(:new).returns(client)
      client.expects(:create_batch).with(has_entry(:body, "[test] #{'A'*153}")).returns(OpenStruct.new({id: "1"}))
      subject.perform(recipient_id: recipient.id, message_id: message.id)
      recipient.reload
      expect(recipient.status).to eq("sending")
      expect(recipient.ack).to eq("1")
    end
  end
end
