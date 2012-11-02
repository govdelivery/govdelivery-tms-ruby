class TwilioStatusCallbacksController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :find_recipient
  respond_to :xml

  def create
    if params['SmsStatus'] == 'sent'
      @recipient.status=Recipient::STATUS_SENT
      @recipient.completed_at = Time.now
    elsif params['SmsStatus'] == 'failed'
      @recipient.status=Recipient::STATUS_FAILED
      @recipient.completed_at = Time.now
    end
    @recipient.save
    render :text => '', :status => 201
  end

  protected
  def find_recipient
    @recipient=Recipient.find_by_ack!(params['SmsSid'])
  end
end
