require 'spec_helper'
describe TwilioVoiceWorker do
  let(:voice_vendor) { create(:voice_vendor, worker: 'TwilioVoiceWorker') }
  let(:account) { voice_vendor.accounts.create!(:name => 'name') }
  let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:message) { account.voice_messages.create!(:play_url => 'http://localhost/file.mp3', :recipients_attributes => [{:phone => "5554443333", :vendor => voice_vendor}]) }

  #need to add recipient stubs and verify recipients are modified correctly
  context 'a send' do
    it 'should create a batch job' do
      message.class.any_instance.expects(:process_blacklist!)
      message.class.any_instance.expects(:sending!)

      Twilio::SenderWorker.expects(:perform_async).with(
        message_class: message.class.name,
        callback_url: nil,
        message_url: nil,
        message_id: message.id,
        recipient_id: message.recipients.first.id)

      subject.perform(message_id: message.id)
    end
  end

end
