require 'rails_helper'

describe TwilioDialPlanController do
  let(:account) { create(:account_with_voice) }
  let(:user) { account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop') }
  let(:message) { account.voice_messages.create(play_url: 'http://mom.com/voice.wav') }
  let(:tts_message) { account.voice_messages.create(say_text: 'hello donkey 1 2 3 4 5') }
  let(:recipient) do
    recipient       = message.recipients.build(phone: '+15551112222')
    recipient.ack = 'CAb8f9080a0f9c5101c8f6a030f8a3bf32'
    recipient.vendor = account.voice_vendor
    recipient.save!
    recipient
  end
  let(:tts_recipient) do
    recipient       = tts_message.recipients.build(phone: '+15551112222')
    recipient.ack = 'AAb8f9080a0f9c5101c8f6a030f8a3bf32'
    recipient.vendor = account.voice_vendor
    recipient.save!
    recipient
  end

  it 'should error when calling #show with a CallSid that is not found' do
    post :show, twilio_dial_plan_params('OH TEH NOES')
    expect(response.response_code).to eq(404)
  end

  it 'should display play_url TwiML when calling #show with a legit CallSid' do
    post :show, twilio_dial_plan_params
    expect(response.response_code).to eq(200)
    expect(response.body).to match(/#{message.play_url}/)
  end

  it 'should display call script when calling #show with a legit CallSid' do
    post :show, twilio_dial_plan_params(tts_recipient.ack)
    expect(response.response_code).to eq(200)
    expect(response.body).to match(/hello donkey 1 2 3 4 5/)
    expect(response.body).to match(/To repeat this message, press 1./)
  end

  def twilio_dial_plan_params(call_sid = recipient.ack)
    { format:   'xml',
      'CallSid' => call_sid
    }
  end
end
