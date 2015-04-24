class TwilioVoiceRequestsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_user_from_token!
  before_action :find_from_number
  respond_to :xml

  def create
    respond_to do |format|
      format.xml {render xml: twiml_response.text}
    end
  end

  private

  def find_from_number
    @from_number = FromNumber.find_by_phone_number(params['To'])
  end

  def twiml_response
    Twilio::TwiML::Response.new do |r|
      if @from_number && @from_number.voice_message
        r.Say @from_number.voice_message.say_text if @from_number.voice_message.say_text
        r.Play @from_number.voice_message.play_url if @from_number.voice_message.play_url
      end
    end
  end
end
