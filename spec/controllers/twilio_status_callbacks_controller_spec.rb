require 'rails_helper'

describe TwilioStatusCallbacksController do
  describe 'SMS vendor' do
    let(:vendor) { create(:sms_vendor) }
    let(:account) { vendor.accounts.create(name: 'name') }
    let(:user) { account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop') }
    let(:message) { account.sms_messages.create(body: 'Look out') }
    let(:recipient) do
      recipient = message.recipients.build(phone: '+15551112222')
      recipient.ack = 'SM2e4152a68a31e52bbf035e22b77f09ab'
      recipient.vendor = vendor
      recipient.save!
      recipient
    end

    it 'should error when calling #create with an SmsSid that is not found' do
      post :create, twilio_status_callback_params('sent ', 'NO THIS IS WRONG')
      expect(response.response_code).to eq(404)
    end

    context '#create with garbage status' do
      before do
        post :create, twilio_status_callback_params('indeterminate')
        recipient.reload
      end
      it 'should respond with accepted' do
        expect(response.response_code).to eq(201)
      end
      it 'should not update recipient status' do
        expect(recipient.new?).to be true
      end
      it 'should not set the completed_at date for the recipient' do
        expect(recipient.completed_at).to eq(nil)
      end
    end

    context '#create with sent' do
      before do
        post :create, twilio_status_callback_params('sent')
      end
      it 'should respond with accepted' do
        expect(response.response_code).to eq(201)
      end
      it 'should update recipient status' do
        expect(recipient.reload.sent?).to be true
      end
      it 'should set the completed_at date for the recipient' do
        expect(recipient.reload.completed_at).not_to eq(nil)
      end
    end

    context '#create with failed' do
      before do
        post :create, twilio_status_callback_params('failed')
        recipient.reload
      end
      it 'should respond with accepted' do
        expect(response.response_code).to eq(201)
      end
      it 'should update recipient status' do
        expect(recipient.failed?).to be true
      end
      it 'should set the completed_at date for the recipient' do
        expect(recipient.completed_at).not_to eq(nil)
      end
    end

    def twilio_status_callback_params(status, sms_sid = recipient.ack)
      { format: 'xml',
        'SmsSid' => sms_sid,
        'SmsStatus' => status
      }
    end
  end
  describe 'Voice vendor' do
    let(:account) { create(:account_with_voice) }
    let(:user) { account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop') }
    let(:message) { account.voice_messages.create(play_url: 'http://ninja.com.website/hello.wav') }
    let(:recipient) do
      recipient = message.recipients.build(phone: '+15551112222')
      recipient.ack = 'SM2e4152a68a31e52bbf035e22b77f09ab'
      recipient.vendor = account.voice_vendor
      recipient.save!
      recipient
    end

    context '#create with human answer' do
      before do
        recipient.sending!('ack')
        message.ready!
        message.sending!
        post :create, twilio_status_callback_params('sent', 'human')
        recipient.reload
      end
      it 'should respond with accepted' do
        expect(response.response_code).to eq(201)
      end
      it 'should update recipient status' do
        expect(recipient.sent?).to be true
      end
      it 'should not update recipient secondary status' do
        expect(recipient.secondary_status).to eql('human')
      end
      it 'should set the completed_at date for the recipient' do
        expect(recipient.completed_at).not_to be_nil
      end
    end

    context '#create with Skynet' do
      before do
        recipient.sending!('ack')
        message.ready!
        message.sending!
        post :create, twilio_status_callback_params('sent', 'machine')
        recipient.reload
      end
      it 'should respond with accepted' do
        expect(response.response_code).to eq(201)
      end
      it 'should update recipient status' do
        expect(recipient.sent?).to be true
      end
      it 'should update recipient secondary status' do
        expect(recipient.secondary_status).to eql('machine')
      end
      it 'should set the completed_at date for the recipient' do
        expect(recipient.completed_at).not_to be_nil
      end
    end

    context '#create with busy' do
      before do
        recipient.sending!('ack')
        message.ready!
        message.sending!
        post :create, twilio_status_callback_params('busy')
        recipient.reload
      end
      it 'should respond with accepted' do
        expect(response.response_code).to eq(201)
      end
      it 'should update recipient status' do
        expect(recipient.failed?).to be true
      end
      it 'should update recipient secondary status' do
        expect(recipient.secondary_status).to eql('busy')
      end
      it 'should set the completed_at date for the recipient' do
        expect(recipient.completed_at).not_to be_nil
      end
    end

    context '#create with no answer' do
      before do
        recipient.sending!('ack')
        message.ready!
        message.sending!
        post :create, twilio_status_callback_params('no-answer')
        recipient.reload
      end
      it 'should respond with accepted' do
        expect(response.response_code).to eq(201)
      end
      it 'should update recipient status' do
        expect(recipient.failed?).to be true
      end
      it 'should update recipient secondary status' do
        expect(recipient.secondary_status).to eql('no_answer')
      end
      it 'should set the completed_at date for the recipient' do
        expect(recipient.completed_at).not_to be_nil
      end
    end

    context '#create with busy and retry' do
      before do
        message.max_retries = 3
        recipient.sending!('ack')
        message.ready!
        message.sending!
        post :create, twilio_status_callback_params('busy')
        recipient.reload
      end
      it 'should respond with accepted' do
        expect(response.response_code).to eq(201)
      end
      it 'should not update recipient status' do
        expect(recipient.sent?).to be false
        expect(recipient.sending?).to be true
      end
      it 'should update recipient secondary status' do
        expect(recipient.voice_recipient_attempts.last.description).to eql('busy')
      end
      it 'should update retry count' do
        expect(recipient.retries).to eql(1)
      end
      it 'should set the completed_at date for the recipient' do
        expect(recipient.completed_at).to be_nil
      end
    end

    context '#create with no answer and retry' do
      before do
        message.max_retries = 3
        recipient.sending!('ack')
        message.ready!
        message.sending!
        post :create, twilio_status_callback_params('no-answer')
        recipient.reload
      end
      it 'should respond with accepted' do
        expect(response.response_code).to eq(201)
      end
      it 'should update recipient status' do
        expect(recipient.sent?).to be false
      end
      it 'should update recipient secondary status' do
        expect(recipient.voice_recipient_attempts.last.description).to eql('no_answer')
      end
      it 'should update retry count' do
        expect(recipient.retries).to eql(1)
      end
      it 'should set the completed_at date for the recipient' do
        expect(recipient.completed_at).to eq(nil)
      end
    end

    context '#create with failed' do
      before do
        message.max_retries = 3
        recipient.sending!('ack')
        message.ready!
        message.sending!
        post :create, twilio_status_callback_params('failed')
        recipient.reload
      end
      it 'should respond with accepted' do
        expect(response.response_code).to eq(201)
      end
      it 'should not update recipient status' do
        expect(recipient.sending?).to be true
      end
      it 'should update retry count' do
        expect(recipient.retries).to eql(1)
      end
      it 'should set the completed_at date for the recipient' do
        expect(recipient.completed_at).to eq(nil)
      end
    end

    def twilio_status_callback_params(status, answeredby = nil, call_sid = recipient.ack)
      { format: 'xml',
        'CallSid' => call_sid,
        'CallStatus' => status,
        'AnsweredBy' => answeredby
      }
    end
  end
end
