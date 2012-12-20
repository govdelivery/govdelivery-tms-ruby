require 'spec_helper'

describe TwilioStatusCallbacksController do
  let(:vendor) { Vendor.create!(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker', :help_text => 'Help me!') }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:message) { account.messages.create(:short_body => 'Look out') }
  let(:recipient) do
    recipient = message.recipients.build(:phone => '+15551112222')
    recipient.ack='SM2e4152a68a31e52bbf035e22b77f09ab'
    recipient.vendor=vendor
    recipient.save!
    recipient
  end
  
  it "should error when calling #create with an SmsSid that is not found" do
    lambda {
      post :create, twilio_status_callback_params('sent ', "NO THIS IS WRONG")
    }.should raise_error(ActiveRecord::RecordNotFound)
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
      recipient.status.should == Recipient::STATUS_NEW
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
      recipient.reload.status.should == Recipient::STATUS_SENT
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
      recipient.status.should == Recipient::STATUS_FAILED
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
