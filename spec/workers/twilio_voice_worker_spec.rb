require 'spec_helper'
describe TwilioVoiceWorker do
  let(:voice_vendor) { Vendor.create!(:voice=>true, :name => 'voice vendor', :username => 'username', :password => 'secret', :from => 'from', :worker => 'TwilioVoiceWorker') }
  let(:account) { account = voice_vendor.accounts.create!(:name => 'name') }
  let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:message) { user.messages.create!(:url => 'http://localhost/file.mp3', :recipients_attributes => [{:phone => "6515551212", :vendor => voice_vendor}]) }

  #need to add recipient stubs and verify recipients are modified correctly
  context 'a very happy send' do
    let(:worker) { TwilioVoiceWorker.new }

    it 'should work' do
      Twilio::REST::Client.expects(:new).with(message.vendor.username, message.vendor.password).returns(OpenStruct.new(:account => ''))
      MessageSender.any_instance.expects(:send!).with(message.recipients, instance_of(Proc))
      worker.perform(:message_id => message.id)
    end

  end

  context 'a sad send' do
    let(:worker) { TwilioVoiceWorker.new }

    it 'should not work' do
      Twilio::REST::Client.expects(:new).with(message.vendor.username, message.vendor.password).returns(OpenStruct.new(:account => ''))
      MessageSender.any_instance.expects(:send!).with(message.recipients, instance_of(Proc)).raises(Exception.new("TWILIO OH TEH NOES!"))
      expect { worker.perform(:message_id => message.id) }.to raise_error
    end

  end

end