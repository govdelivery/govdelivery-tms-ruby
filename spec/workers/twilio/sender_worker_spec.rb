require 'spec_helper'

describe Twilio::SenderWorker do
  context 'a voice send' do
    let(:voice_vendor) { create(:voice_vendor, worker: 'TwilioVoiceWorker') }
    let(:account) { voice_vendor.accounts.create!(:name => 'name') }
    let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
    let(:message) { account.voice_messages.create!(:play_url => 'http://localhost/file.mp3', :recipients_attributes => [{:phone => "5554443333", :vendor => voice_vendor}]) }


    #need to add recipient stubs and verify recipients are modified correctly
    context 'a very happy send' do
      it 'should work' do
        twilio_calls = mock
        twilio_calls.expects(:create).returns(OpenStruct.new(:sid => 'abc123', :status => 'completed'))
        Twilio::REST::Client.expects(:new).with(message.vendor.username, message.vendor.password).returns(OpenStruct.new(:account => OpenStruct.new(:calls => twilio_calls)))
        expect { subject.perform(
          message_id: message.id,
          message_class: message.class.name,
          recipient_id: message.recipients.first.id,
          callback_url: 'http://localhost')
        }.to change { message.recipients.where(:ack => 'abc123').count }.by 1
      end
    end

    context 'a sad send' do
      it 'should not work' do
        twilio_calls = mock
        twilio_calls.expects(:create).raises(Twilio::REST::RequestError.new('error'))
        Twilio::REST::Client.expects(:new).with(message.vendor.username, message.vendor.password).returns(OpenStruct.new(:account => OpenStruct.new(:calls => twilio_calls)))
        expect { subject.perform(
          message_id: message.id,
          message_class: message.class.name,
          recipient_id: message.recipients.first.id,
          callback_url: 'http://localhost')
        }.to change { message.recipients.where(:error_message => 'error').count }.by 1
      end
    end
  end
end
