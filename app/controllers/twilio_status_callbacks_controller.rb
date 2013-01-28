class TwilioStatusCallbacksController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :get_status, :find_recipient
  respond_to :xml

  def create
    status = case @status
               when 'sent', 'completed', 'busy', 'no-answer'
                 RecipientStatus::SENT
               when 'failed'
                 RecipientStatus::FAILED
               when 'canceled'
                 RecipientStatus::CANCELED
             end
    @recipient.complete!(:status => status)
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
  end

  def find_recipient
    @recipient=if params.has_key?('SmsStatus')
                 SmsRecipient.find_by_ack!(params['SmsSid'])
               elsif params.has_key?('CallStatus')
                 VoiceRecipient.find_by_ack!(params['CallSid'])
               else
                 nil
               end
  end

end
