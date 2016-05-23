class TwilioStatusCallbacksController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_user_from_token!
  respond_to :xml

  def create
    Twilio::StatusWorker.perform_async({
      status: params['MessageStatus'] || params['CallStatus'] || '',
      answered_by: params['AnsweredBy'],
      sid: params['MessageSid'] || params['CallSid'],
      type: params.key?('MessageStatus') ? 'sms' : 'voice'
    })
    render text: '', status: 201
  end
end
