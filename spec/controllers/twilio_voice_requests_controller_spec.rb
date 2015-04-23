require 'rails_helper'

describe TwilioVoiceRequestsController, '#create' do
  before :each do
    @account = create(:account_with_voice)
    @account.default_from_number.incoming_voice_messages.create(say_text: 'hello world', is_default: true)
  end

  it 'should return empty on a non-existant FromNumber' do
    post :create, twilio_voice_request_params(@account).merge('To' => '+1bensphone')
    expect(response.response_code).to eq(200)
    expect(response.body).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response></Response>")
  end

  it 'should return default message' do
    post :create, twilio_voice_request_params(@account)
    expect(response.response_code).to eq(200)
    expect(response.body).to match(/hello world/)
  end

  def twilio_voice_request_params(account)
    @sid ||= ('0' * 34)
    @sid.succ!
    {format: 'xml',
     'CallSid' => @sid,
     'AccountSid' => account.voice_vendor.username,
     'From' => '+15555555555',
     'To' => account.from_number,
     'Direction' => 'inbound'}
  end
end
