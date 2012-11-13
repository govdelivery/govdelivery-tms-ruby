require File.dirname(__FILE__) + '/../spec_helper'

describe TwilioRequestsController do
  let(:vendor) { Vendor.create!(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker', :help_text => 'Help me!') }

  it "should error when calling #create with an incorrect AccountSid" do
    lambda {
      post :create, twilio_request_params('HELP ', "NO THIS IS WRONG")
    }.should raise_error(ActiveRecord::RecordNotFound)
  end
  
  context "#create with garbage" do
    before do
      Vendor.any_instance.expects(:inbound_messages).returns(mock('inbound_messages', :'create!' => true))
      post :create, twilio_request_params('come to pazzaluna after work')
    end
    it "should respond with accepted" do
      response.response_code.should == 201
    end
  end

  context "#create with HELP" do
    before do
      post :create, twilio_request_params(' HELP')
    end
    it "should respond with accepted" do
      response.response_code.should == 201
    end
  end
  
  context "#create with STOP" do
    before do
      body = ' sToP'
      Vendor.expects(:find_by_username!).with(vendor.username).returns(vendor)
      mock_parser = mock(:parse! => true)
      RequestParser.expects(:new).with(vendor, body, '+15551112222').returns(mock_parser)
      mock_response = mock(:new_record? => false)
      View::TwilioRequestResponse.expects(:new).returns(mock_response)
      post :create, twilio_request_params(body)
    end
    it "should respond with accepted" do
      response.response_code.should == 201
    end
  end

  def twilio_request_params(body, account_id=vendor.username)
    @sid ||= ('0'*34)
    @sid.succ!
    {:format =>"xml" ,
     'SmsSid'=>@sid,
     'AccountSid'=>account_id,
     'From'=>'+15551112222',
     'To'=>'',
     'Body'=>body
    }
  end
end
