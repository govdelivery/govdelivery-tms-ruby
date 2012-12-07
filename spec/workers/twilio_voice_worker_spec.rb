require 'spec_helper'
describe TwilioVoiceWorker do
  let(:voice_vendor) { Vendor.create!(:voice=>true, :name => 'voice vendor', :username => 'username', :password => 'secret', :from => 'from', :worker => 'TwilioVoiceWorker') }
  let(:account) { account = voice_vendor.accounts.create!(:name => 'name') }
  let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:message) { user.messages.create!(:url => 'http://localhost/file.mp3') }


  context 'a very happy send' do
    let(:worker) { TwilioVoiceWorker.new }

    it 'should work' do
      Twilio::REST::Client.expects(:new).with(message.vendor.username, message.vendor.password).returns(OpenStruct.new(:account => ''))
      MessageSender.expects(:new).with() do |*args|
        from, proc = args
        from.should == voice_vendor.from
        proc.public_method(:call).should_not be_nil
      end
      worker.perform(:message_id => 1)
    end

  end

end