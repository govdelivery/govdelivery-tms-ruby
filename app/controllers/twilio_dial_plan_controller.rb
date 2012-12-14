class TwilioDialPlanController < ApplicationController 
  skip_before_filter :authenticate_user!

  def show
    recipient = Recipient.scoped(:conditions => {:ack => params['CallSid']}).first
    if !recipient.nil?
      @message = Message.find_by_id(recipient.message_id)
    end
    #TODO rescue bad SID for message
    respond_to do |format|
        format.xml { @message }
    end
  end
end