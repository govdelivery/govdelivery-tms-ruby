require 'rails_helper'

describe TwilioStatusCallbacksController do
  describe 'voice payload' do
    let (:params) do
      {
        format: 'xml',
        'CallStatus' => '1234',
        'CallSid' => '5678',
        'AnsweredBy' => 'abcd'
      }
    end

    it 'should background the status worker and always succeed' do
      Twilio::StatusWorker.expects(:perform_async).with(status: '1234', answered_by: 'abcd', sid: '5678', type: 'voice')
      post :create, params
      expect(response.response_code).to eq(201)
    end
  end

  describe 'sms payload' do
    let (:params) do
      {
        format: 'xml',
        'SmsSid' => '5678',
        'SmsStatus' => '1234'
      }
    end
    it 'should background the status worker and always succeed' do
      Twilio::StatusWorker.expects(:perform_async).with(status: '1234', answered_by: nil, sid: '5678', type: 'sms')
      post :create, params
      expect(response.response_code).to eq(201)
    end
  end
end
