class TwilioDialPlanController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :find_recipient
  respond_to :xml

  def show
    if !@recipient.nil?
      @message = @recipient.message
    end
    respond_to do |format|
        format.xml { @message }
    end
  end
  def find_recipient
    @recipient=VoiceRecipient.find_by_ack!(params['CallSid'])
  end
end