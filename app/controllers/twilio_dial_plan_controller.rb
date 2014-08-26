class TwilioDialPlanController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_user_from_token!
  before_filter :find_recipient
  respond_to :xml

  def show
    if !@recipient.nil?
      @message = @recipient.message
    end
    respond_to do |format|
      format.xml { render xml: twiml_response(@message).text }
    end
  end

  def find_recipient
    @recipient=VoiceRecipient.includes(message: :call_script).find_by_ack!(params['CallSid'])
  end

  def twiml_response(message)
    Twilio::TwiML::Response.new do |r|
      if message.play_url
        r.Say "Please stand by for an important message."
        r.Play message.play_url
      elsif message.call_script
        r.Gather(action: twiml_url, numDigits: 1) do
          r.Say message.call_script.say_text, voice: 'alice', language: 'en-GB'
          r.Say "To repeat this message, press 1.", voice: 'alice', language: 'en-GB'
        end
      end
    end
  end
end