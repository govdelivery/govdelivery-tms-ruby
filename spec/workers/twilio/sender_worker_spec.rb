require 'rails_helper'
require File.expand_path('../../../../app/workers/base', __FILE__)

describe Twilio::SenderWorker do
  context 'a voice send' do
    let(:account) {create(:account_with_voice)}
    let(:user) {account.users.create!(email: 'foo@evotest.govdelivery.com', password: 'schwoop')}
    let(:message) {account.voice_messages.create!(play_url: 'http://localhost/file.mp3', recipients_attributes: [{phone: '5554443333', vendor: account.voice_vendor}])}
    let(:client) {stub}

    # need to add recipient stubs and verify recipients are modified correctly
    context 'a very happy send' do
      it 'should work' do
        twilio_calls = mock('calls', create: OpenStruct.new(sid: 'abc123', status: 'completed'))
        client.stubs(:account).returns(stub('calls', calls: twilio_calls))
        Twilio::REST::Client.expects(:new).with(message.vendor.username, message.vendor.password).returns(client)
        expect do
          subject.perform(
            message_id: message.id,
            message_class: message.class.name,
            recipient_id: message.recipients.first.id,
            callback_url: 'http://localhost')
        end.to change {message.recipients.where(ack: 'abc123').count}.by 1
      end
    end

    [401, 404, 429, 500].each do |response|
      context "a send that returns a #{response} from Twilio" do
        it 'should raise an exception' do
          twilio_calls = mock
          twilio_calls.expects(:create).raises(Twilio::REST::RequestError.new('error'))
          client.expects(:last_response).returns(Net::HTTPBadRequest.new(response.to_s, response, 'yarrr'))
          client.stubs(:account).returns(stub('calls', calls: twilio_calls))
          Twilio::REST::Client.expects(:new).with(message.vendor.username, message.vendor.password).returns(client)
          expect do
            subject.perform(
              message_id: message.id,
              message_class: message.class.name,
              recipient_id: message.recipients.first.id,
              callback_url: 'http://localhost')
          end.to raise_exception(Sidekiq::Retries::Retry)
        end
      end
    end

    context 'a send that returns a 400 from Twilio' do
      it 'should fail the recipient but not the job' do
        response = 400
        twilio_calls = mock
        twilio_calls.expects(:create).raises(Twilio::REST::RequestError.new('error'))
        client.expects(:last_response).returns(Net::HTTPBadRequest.new(response.to_s, response, 'yarrr'))
        client.stubs(:account).returns(stub('calls', calls: twilio_calls))
        Twilio::REST::Client.expects(:new).with(message.vendor.username, message.vendor.password).returns(client)
        subject.perform(
          message_id:    message.id,
          message_class: message.class.name,
          recipient_id:  message.recipients.first.id,
          callback_url:  'http://localhost')

        recipient = message.recipients.first
        expect(recipient.ack).to be nil
        expect(recipient.status).to eq 'failed'
        expect(recipient.error_message).to eq 'error'
      end
    end

    context 'a send that blows up because we such' do
      it 'should retry on runtime errors' do
        subject.expects(:find_message_and_recipient).raises(RuntimeError, 'foo')
        client.stubs(:account).returns(stub('calls', calls: mock))
        expect do
          subject.perform(
            message_id:    message.id,
            message_class: message.class.name,
            recipient_id:  message.recipients.first.id,
            callback_url:  'http://localhost')
        end.to raise_exception(Sidekiq::Retries::Retry)
      end

      it 'should retry on db connection errors' do
        message.class.expects(:find).with(message.id).raises(ActiveRecord::ConnectionTimeoutError.new('oopz'))
        client.stubs(:account).returns(stub('calls', calls: mock))
        expect do
          subject.perform(
              message_id:    message.id,
              message_class: message.class.name,
              recipient_id:  message.recipients.first.id,
              callback_url:  'http://localhost')
        end.to raise_exception(Sidekiq::Retries::Retry)
      end
    end

    context 'a send that succeed but then fails to update the recipient' do
      it 'should not retry' do
        twilio_calls = mock
        twilio_calls.expects(:create).returns(OpenStruct.new(sid: 'abc123', status: 'completed'))
        Twilio::REST::Client.expects(:new).with(message.vendor.username, message.vendor.password).returns(OpenStruct.new(account: OpenStruct.new(calls: twilio_calls)))
        ex = ActiveRecord::ConnectionTimeoutError.new('this could be anything')
        Service::TwilioResponseMapper.expects(:recipient_callback).raises(ex)
        message.recipients.first.class.expects(:delay).returns(mock('DelayedClass', transition: 'yup'))
        expect do
          subject.perform(
            message_id: message.id,
            message_class: message.class.name,
            recipient_id: message.recipients.first.id,
            callback_url: 'http://localhost')
        end.to raise_exception(ActiveRecord::ConnectionTimeoutError, 'this could be anything')
      end
    end
  end
end
