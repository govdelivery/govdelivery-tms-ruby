require 'spec_helper'

describe TwilioDialPlanController do
  let(:vendor) { create(:voice_vendor) }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:message) { account.voice_messages.create(:play_url => "http://mom.com/voice.wav") }
  let(:recipient) do
    recipient = message.recipients.build(:phone => '+15551112222')
    recipient.ack='CAb8f9080a0f9c5101c8f6a030f8a3bf32'
    recipient.vendor=vendor
    recipient.save!
    recipient
  end

  it "should error when calling #show with a CallSid that is not found" do
    post :show, twilio_dial_plan_params("OH TEH NOES")
    response.response_code.should == 404
  end

  it "should display TwiML when calling #show with a legit CallSid" do
    post :show, twilio_dial_plan_params
    response.response_code.should == 200
  end

  def twilio_dial_plan_params(call_sid=recipient.ack)
    {:format =>"xml" ,
     'CallSid'=>call_sid
    }
  end
end
