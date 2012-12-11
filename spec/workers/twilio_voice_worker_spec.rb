require 'spec_helper'
describe TwilioVoiceWorker do
  let(:voice_vendor) { Vendor.create!(:voice=>true, :name => 'voice vendor', :username => 'username', :password => 'secret', :from => 'from', :worker => 'TwilioVoiceWorker') }
  let(:account) { account = voice_vendor.accounts.create!(:name => 'name') }
  let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:message) { user.messages.create!(:url => 'http://localhost/file.mp3', :recipients_attributes => [{:phone => "6515551212", :vendor => voice_vendor}]) }

  context 'a very happy send' do
    let(:worker) { TwilioVoiceWorker.new }

    it 'should work' do
      Twilio::REST::Client.expects(:new).with(message.vendor.username, message.vendor.password).returns(OpenStruct.new(:account => ''))
      MessageSender.any_instance.expects(:send!).with(message.recipients, instance_of(Proc))
      worker.perform(:message_id => 1)
    end

  end

end