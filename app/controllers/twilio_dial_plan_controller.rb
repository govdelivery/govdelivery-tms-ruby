class TwilioDialPlanController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_user_from_token!
  before_action :find_recipient
  respond_to :xml

  def show
    @message = @recipient.message unless @recipient.nil?
    respond_to do |format|
      format.xml { render xml: twiml_response(@message).text }
    end
  end

  def find_recipient
    @recipient = VoiceRecipient.includes(message: :call_script).find_by_ack!(params['CallSid'])
  end

  def twiml_response(message)
    Twilio::TwiML::Response.new do |r|
      if message.play_url
        r.Play message.play_url
      elsif message.call_script
        r.Gather(action: twiml_url, numDigits: 1) do
          r.Say message.call_script.say_text, voice: 'man'
          r.Say 'To repeat this message, press 1.', voice: 'man'
        end
      end
    end
  end
end
