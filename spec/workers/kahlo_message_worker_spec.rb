require 'rails_helper'
describe KahloMessageWorker do
  let(:sms_vendor) { create(:sms_vendor, worker: 'KahloMessageWorker') }
  let(:account) { sms_vendor.accounts.create!(name: 'name') }
  let(:user) { account.users.create!(email: 'foo@evotest.govdelivery.com', password: 'schwoop') }
  let(:message) { account.sms_messages.create!(body: 'hello, message worker!') }
  let(:recipient) { message.recipients.create!(phone: '5554443333') }

  # need to add recipient stubs and verify recipients are modified correctly
  context 'a send' do

    context 'with a message in sending state' do
      before do
        message.class.any_instance.stubs(:may_sending?).returns(true)
        message.class.any_instance.expects(:sending!)
      end
      it 'should create a batch job' do
        Kahlo::SenderWorker.expects(:perform_async).with(message_id: message.id, recipient_id: recipient.id, message_type: Rails.configuration.sms_default_message_type)
        subject.perform(message_id: message.id)
      end

      it 'should create a batch job with a custom message type' do
        account.class.any_instance.stubs(:sms_message_type).returns('urgent')
        Kahlo::SenderWorker.expects(:perform_async).with(message_id: message.id, recipient_id: recipient.id, message_type: 'urgent')
        subject.perform(message_id: message.id)
      end
    end

    it 'should fail if not in sending state' do
      Kahlo::SenderWorker.expects(:perform_async).never
      expect { subject.perform(message_id: message.id) }.to raise_error Sidekiq::Retries::Retry
    end
  end
end
