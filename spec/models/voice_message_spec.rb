require 'rails_helper'

describe VoiceMessage do
  let(:account) { create(:account_with_voice) }
  let(:user) { account.users.create!(email: 'foo@evotest.govdelivery.com', password: 'schwoop') }

  context 'a voice message' do
    let(:message) { account.voice_messages.build(play_url: 'http://localhost/file.mp3') }

    subject { message }
    it { is_expected.to be_valid }
  end

  context 'a voice message with nil retry' do
    let(:message) { account.voice_messages.create(play_url: 'http://localhost/file.mp3', max_retries: nil) }

    subject! { message }
    it { expect(subject.max_retries).to eq(0) }
  end

  context 'a voice message with nil retry_delay' do
    let(:message) { account.voice_messages.create(play_url: 'http://localhost/file.mp3', retry_delay: nil) }

    subject! { message }
    it { expect(subject.retry_delay).to eq(300) }
  end

  context 'a voice message with a script' do
    let(:message) { account.voice_messages.create!(say_text: 'Your Gov Delivery authorization code is 1 2 3 4 5. Thank you for using Gov Delivery. This message will repeat.') }

    subject { message }
    it { expect(subject.call_script).not_to be_nil }

    context 'recipient filters' do
      { failed: 'error_message', sent: 'human' }.each do |type, arg|
        context "with recips who #{type}" do
          before do
            subject.recipients.create!(phone: '5555555555')

            recip = subject.recipients.reload.first
            recip.send(:"#{type}!", 'ack', nil, arg)
          end
          it { expect(subject.send(:"recipients_who_#{type}").count).to eq(1) }
        end
      end
    end
  end

  context 'an account with voice and sms senders' do
    let(:message) { account.voice_messages.create!(play_url: 'http://localhost/file.mp3') }
    before do
      account.save!
    end
    it 'should return correct worker' do
      expect(message.worker).to eq(TwilioVoiceWorker)
    end
    it 'should return correct from_number' do
      expect(message.from_number).to eq(account.from_number)
    end
    context 'being marked ready' do
      before do
        message.expects(:process_blacklist!)
        expect(message.ready!(nil, [{ phone: '4054343424' }])).to be true
      end

      context 'being marked as sending' do
        before do
          expect(message.sending!).to be true
        end
        specify do
          expect(message.recipients.first.new?).to be true
        end
      end
    end

    context 'with invalid recipient' do
      it 'should blow up' do
        expect { message.ready!([{ phone: nil }]) }.to raise_error(AASM::InvalidTransition)
      end
    end

    context 'with valid recipient' do
      before { message.create_recipients([{ phone: '6093433422' }]) }
      specify { expect(message.recipients.first).to be_valid }
      specify { expect(message.sendable_recipients.first).to be_valid }
      specify { expect(message).to respond_to(:process_blacklist!) }
      specify { expect(message.recipients.first.vendor).to eq(account.voice_vendor) }
    end
  end
end
