require 'rails_helper'
describe TwilioMessageWorker do
  let(:sms_vendor) { create(:sms_vendor, :worker => 'TwilioMessageWorker') }
  let(:account) { account = sms_vendor.accounts.create!(:name => 'name') }
  let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:message) { account.sms_messages.create!(:body => 'hello, message worker!', :recipients_attributes => [{:phone => "5554443333", :vendor => sms_vendor}]) }

  #need to add recipient stubs and verify recipients are modified correctly
  context 'a send' do
    it 'should create a batch job' do
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

