class TwilioStatusCallbacksController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_user_from_token!
  respond_to :xml

  def create
    Twilio::StatusWorker.perform_async({
      status: params['SmsStatus'] || params['CallStatus'] || '',
      answered_by: params['AnsweredBy'],
      sid: params['SmsSid'] || params['CallSid'],
      type: params.key?('SmsStatus') ? 'sms' : 'voice'
    })
    render text: '', status: 201
  end
end
