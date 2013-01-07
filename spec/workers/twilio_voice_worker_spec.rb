require 'spec_helper'
describe TwilioVoiceWorker do
  let(:voice_vendor) { Vendor.create!(:name => 'voice vendor', :username => 'username', :password => 'secret', :from => 'from', :worker => 'TwilioVoiceWorker') }
  let(:account) { account = voice_vendor.accounts.create!(:name => 'name') }
  let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:message) { account.messages.create!(:url => 'http://localhost/file.mp3', :recipients_attributes => [{:phone => "6515551212", :vendor => voice_vendor}]) }

  #need to add recipient stubs and verify recipients are modified correctly
  context 'a very happy send' do
    let(:worker) { TwilioVoiceWorker.new }

    it 'should work' do
      twilio_calls = mock
      twilio_calls.expects(:create).returns(OpenStruct.new(:sid => 'abc123', :status => 'completed'))
      Twilio::REST::Client.expects(:new).with(message.vendor.username, message.vendor.password).returns(OpenStruct.new(:account => OpenStruct.new(:calls => twilio_calls)))
      expect { worker.perform(:message_id => message.id) }.to change { message.recipients.where(:ack => 'abc123').count }.by 1
    end
  end

  context 'a sad send' do
    let(:worker) { TwilioVoiceWorker.new }

    it 'should not work' do
      twilio_calls = mock
      twilio_calls.expects(:create).raises(Twilio::REST::RequestError.new('error'))
      Twilio::REST::Client.expects(:new).with(message.vendor.username, message.vendor.password).returns(OpenStruct.new(:account => OpenStruct.new(:calls => twilio_calls)))
      expect { worker.perform(:message_id => message.id) }.to change { message.recipients.where(:error_message => 'error').count }.by 1
    end
  end

end