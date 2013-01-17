class TwilioStatusCallbacksController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :find_recipient
  respond_to :xml

  def create
    status = case params['SmsStatus']
               when 'sent'
                 RecipientStatus::SENT
               when 'failed'
                 RecipientStatus::FAILED
             end
    @recipient.complete!(:status => status)
    render :text => '', :status => 201
  end

  protected
  def find_recipient
    @recipient=SmsRecipient.find_by_ack!(params['SmsSid'])
  end

end
