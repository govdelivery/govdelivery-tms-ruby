class TwilioStatusCallbacksController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_user_from_token!
  before_filter :find_recipient
  respond_to :xml

  def create
    begin
      args = [@sid, nil]
      args << secondary_status if params.has_key?('CallStatus')
      @recipient.send(transition, *args)
    rescue Recipient::ShouldRetry  #call came back as busy, no answer, or fail...retry
      if @recipient.sending?
        args = {message_id: @recipient.message.id,
                recipient_id: @recipient.id,
                message_url: twiml_url,
                callback_url: twilio_status_callbacks_url(:format => :xml)}
        @recipient.message.worker.perform_in(@recipient.message.retry_delay.seconds, args)
      end
    ensure
      render :text => '', :status => 201
    end
  end

  protected
  def transition
    Service::TwilioResponseMapper.recipient_callback(params['SmsStatus'] || params['CallStatus'] || '')
  end

  def secondary_status
    Service::TwilioResponseMapper.secondary_status(params['CallStatus'], params['AnsweredBy'])
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
