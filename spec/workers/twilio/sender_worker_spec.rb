require 'rails_helper'

describe Twilio::SenderWorker do
  context 'a voice send' do
    let(:voice_vendor) { create(:voice_vendor, worker: 'TwilioVoiceWorker') }
    let(:account) { voice_vendor.accounts.create!(:name => 'name') }
    let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
    let(:message) { account.voice_messages.create!(:play_url => 'http://localhost/file.mp3', :recipients_attributes => [{:phone => "5554443333", :vendor => voice_vendor}]) }
    let(:client) { stub }


    #need to add recipient stubs and verify recipients are modified correctly
    context 'a very happy send' do
      it 'should work' do
        twilio_calls = mock('calls', create: OpenStruct.new(:sid => 'abc123', :status => 'completed'))
        client.stubs(:account).returns(stub('calls', calls: twilio_calls))
        Twilio::REST::Client.expects(:new).with(message.vendor.username, message.vendor.password).returns(client)
        expect { subject.perform(
          message_id: message.id,
          message_class: message.class.name,
          recipient_id: message.recipients.first.id,
          callback_url: 'http://localhost')
        }.to change { message.recipients.where(:ack => 'abc123').count }.by 1
      end
    end

    [401, 404, 429, 500].each do |response|
      context "a send that returns a #{response} from Twilio" do
        it 'should raise an exception' do
          twilio_calls = mock
          twilio_calls.expects(:create).raises(Twilio::REST::RequestError.new('error'))
          client.expects(:last_response).returns(Net::HTTPBadRequest.new(response.to_s, response, "yarrr"))
          client.stubs(:account).returns(stub('calls', calls: twilio_calls))
          Twilio::REST::Client.expects(:new).with(message.vendor.username, message.vendor.password).returns(client)
          expect { subject.perform(
            message_id: message.id,
            message_class: message.class.name,
            recipient_id: message.recipients.first.id,
            callback_url: 'http://localhost')
          }.to raise_exception(Twilio::REST::RequestError, 'error')
        end
      end
    end

    context "a send that returns a 400 from Twilio" do
      it 'should fail the message but not the job' do
        response = 400
        twilio_calls = mock
        twilio_calls.expects(:create).raises(Twilio::REST::RequestError.new('error'))
        client.expects(:last_response).returns(Net::HTTPBadRequest.new(response.to_s, response, "yarrr"))
        client.stubs(:account).returns(stub('calls', calls: twilio_calls))
        Twilio::REST::Client.expects(:new).with(message.vendor.username, message.vendor.password).returns(client)
        expect { subject.perform(
          message_id: message.id,
          message_class: message.class.name,
          recipient_id: message.recipients.first.id,
          callback_url: 'http://localhost')
        }.to change { message.recipients.where(:error_message => 'error').count }.by 1
      end
    end

    context "a send that blows up because we such" do
      it 'should retry' do
        response     = 400
        twilio_calls = mock
        subject.expects(:find_message_and_recipient).raises(RuntimeError, 'foo')
        client.stubs(:account).returns(stub('calls', calls: twilio_calls))
        expect { subject.perform(
          message_id:    message.id,
          message_class: message.class.name,
          recipient_id:  message.recipients.first.id,
          callback_url:  'http://localhost')
        }.to raise_exception(Sidekiq::Retries::Retry)
      end
    end

    context 'a send that succeed but then fails to update the recipient' do
      it 'should not retry' do
        twilio_calls = mock
        twilio_calls.expects(:create).returns(OpenStruct.new(:sid => 'abc123', :status => 'completed'))
        Twilio::REST::Client.expects(:new).with(message.vendor.username, message.vendor.password).returns(OpenStruct.new(:account => OpenStruct.new(:calls => twilio_calls)))
        ex = RuntimeError.new('this could be anything')
        subject.expects(:complete_recipient!).raises(ex)
        expect { subject.perform(
          message_id: message.id,
          message_class: message.class.name,
          recipient_id: message.recipients.first.id,
          callback_url: 'http://localhost')
        }.to raise_exception(RuntimeError, 'this could be anything')
      end
    end


    context 'on retries exhausted' do
      it 'should fail with error_message' do
        expect { subject.complete_recipient_with_error!(
          {message_id: message.id,
           message_class: message.class.name,
           recipient_id: message.recipients.first.id,
           callback_url: 'http://localhost'},
          'error!'
        )
        }.to change { message.recipients.where(:error_message => 'error!').count }.by 1
      end
    end
  end
end
