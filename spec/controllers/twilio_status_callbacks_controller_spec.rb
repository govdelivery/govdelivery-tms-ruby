require 'spec_helper'

describe TwilioStatusCallbacksController do
  let(:vendor) { create(:sms_vendor, :help_text => 'Help me!') }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:message) { account.sms_messages.create(:body => 'Look out') }
  let(:recipient) do
    recipient = message.recipients.build(:phone => '+15551112222')
    recipient.ack='SM2e4152a68a31e52bbf035e22b77f09ab'
    recipient.vendor=vendor
    recipient.save!
    recipient
  end

  it "should error when calling #create with an SmsSid that is not found" do
    post :create, twilio_status_callback_params('sent ', "NO THIS IS WRONG")
    response.response_code.should == 404
  end

  context "#create with garbage status" do
    before do
      post :create, twilio_status_callback_params('indeterminate')
      recipient.reload
    end
    it "should respond with accepted" do
      response.response_code.should == 201
    end
    it "should not update recipient status" do
      recipient.status.should == RecipientStatus::NEW
    end
    it "should not set the completed_at date for the recipient" do
      recipient.completed_at.should == nil
    end
  end

  context "#create with sent" do
    before do
      post :create, twilio_status_callback_params('sent')
    end
    it "should respond with accepted" do
      response.response_code.should == 201
    end
    it "should update recipient status" do
      recipient.reload.status.should == RecipientStatus::SENT
    end
    it "should set the completed_at date for the recipient" do
      recipient.reload.completed_at.should_not == nil
    end
  end

  context "#create with failed" do
    before do
      post :create, twilio_status_callback_params('failed')
      recipient.reload
    end
    it "should respond with accepted" do
      response.response_code.should == 201
    end
    it "should update recipient status" do
      recipient.status.should == RecipientStatus::FAILED
    end
    it "should set the completed_at date for the recipient" do
      recipient.completed_at.should_not == nil
    end
  end
  
  def twilio_status_callback_params(status, sms_sid=recipient.ack)
    {:format =>"xml" ,
     'SmsSid'=>sms_sid,
     'SmsStatus'=>status
    }
  end
end
