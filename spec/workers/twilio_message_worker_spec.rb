require 'rails_helper'
describe TwilioMessageWorker do
  let(:sms_vendor) { create(:sms_vendor, worker: 'TwilioMessageWorker') }
  let(:account) { sms_vendor.accounts.create!(name: 'name') }
  let(:user) { account.users.create!(email: 'foo@evotest.govdelivery.com', password: 'schwoop') }
  let(:message) { account.sms_messages.create!(body: 'hello, message worker!') }
  let(:recipient) { message.recipients.create!(phone: '5554443333') }

  # need to add recipient stubs and verify recipients are modified correctly
  context 'a send' do
    it 'should create a batch job' do
      message.class.any_instance.stubs(:may_sending?).returns(true)
      message.class.any_instance.expects(:sending!)

      Twilio::SenderWorker.expects(:perform_async).with(
        message_class: message.class.name,
        callback_url: nil,
        message_url:  nil,
        message_id: message.id,
        recipient_id: recipient.id)

      subject.perform(message_id: message.id)
    end

    it 'should fail if not in sending state' do
      Twilio::SenderWorker.expects(:perform_async).never
      expect { subject.perform(message_id: message.id) }.to raise_error Sidekiq::Retries::Retry
    end
  end
end
