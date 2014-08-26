class TwilioStatusCallbacksController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_user_from_token!
  before_filter :get_status, :find_recipient
  respond_to :xml

  def create
    @recipient.send(@transition, @sid)
    render :text => '', :status => 201
  end

  protected
  def get_status
    @status = if params.has_key?('SmsStatus')
                params['SmsStatus']
              elsif params.has_key?('CallStatus')
                params['CallStatus']
              else
                ''
              end
    @transition = Service::TwilioResponseMapper.recipient_callback(@status)
  end

  def find_recipient
    @recipient=if params.has_key?('SmsStatus')
                 @sid = params['SmsSid']
                 SmsRecipient.find_by_ack!(@sid)
               elsif params.has_key?('CallStatus')
                 @sid = params['CallSid']
                 VoiceRecipient.find_by_ack!(@sid)
               else
                 nil
               end
  end

end
