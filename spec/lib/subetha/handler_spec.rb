require 'rails_helper'

describe Subetha::Handler do
  context 'auth' do

    context 'bad credentials' do
      let(:message_context) do
        stub('message_context',
             authentication_handler: stub('authentication_handler', identity: 'WRONNNNG'))
      end
      subject { Subetha::Handler.new(message_context) }

      it 'should reject with invalid creds' do
        expect do
          subject.from('hi@mom.com')
        end.to raise_error org.subethamail.smtp.RejectException
      end
    end

    context 'good credentials' do
      let(:account) { create(:account, email_vendor: create(:email_vendor)) }
      let(:user) { create(:user, account: account) }
      let(:message_context) do
        stub('message_context',
             authentication_handler: stub('authentication_handler', identity: user.authentication_tokens.first.token))
      end
      subject { Subetha::Handler.new(message_context) }

      it 'should work' do
        subject.from('hi@mom.com')
        expect(subject.user).to eq(user)
      end
    end

    context 'good credentials with email disabled' do
      let(:account) { create(:account) }
      let(:user) { create(:user, account: account) }
      let(:message_context) do
        stub('message_context',
             authentication_handler: stub('authentication_handler', identity: user.authentication_tokens.first.token))
      end
      subject { Subetha::Handler.new(message_context) }

      it 'should reject' do
        expect do
          subject.from('hi@mom.com')
        end.to raise_error org.subethamail.smtp.RejectException
      end
    end
  end

  context 'sending an email' do
    let(:account) { create(:account, email_vendor: create(:email_vendor)) }
    let(:user) { create(:user, account: account) }
    let(:message) { File.read(Rails.root.join('test', 'fixtures', 'message.eml')) }
    let(:message_no_subject) { File.read(Rails.root.join('test', 'fixtures', 'invalid_message.eml')) }
    subject do
      Subetha::Handler.new(nil).tap do |h|
        h.user=user
      end
    end

    it 'should work' do
      CreateRecipientsWorker.expects(:perform_async)
      subject.data(StringIO.new(message).to_inputstream)
      expect(subject.message).not_to be_nil
      expect(subject.message.persisted?).to be true
    end

    it 'should fail if message is invalid' do
      expect do
        subject.data(StringIO.new(message_no_subject).to_inputstream)
      end.to raise_error org.subethamail.smtp.RejectException
    end
  end
end