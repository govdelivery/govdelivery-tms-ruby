require 'rails_helper'
describe TwilioVoiceWorker do
  let(:account){ create(:account_with_voice) }
  let(:user) { account.users.create!(email: 'foo@evotest.govdelivery.com', password: "schwoop") }
  let(:message) { account.voice_messages.create!(play_url: 'http://localhost/file.mp3', recipients_attributes: [{phone: "5554443333", vendor: account.voice_vendor}]) }

  #need to add recipient stubs and verify recipients are modified correctly
  context 'a send' do
    it 'should create a batch job' do
      message.class.any_instance.stubs(:queued?).returns(true)
      message.class.any_instance.expects(:sending!)

      Twilio::SenderWorker.expects(:perform_async).with(
          message_class: message.class.name,
          callback_url: nil,
          message_url:  nil,
          message_id: message.id,
          recipient_id: message.recipients.first.id)

      subject.perform(message_id: message.id)
    end
  end

  it 'should fail if not in sending state' do
    Twilio::SenderWorker.expects(:perform_async).never
    expect { subject.perform(message_id: message.id) }.to raise_error Sidekiq::Retries::Retry
  end

end
