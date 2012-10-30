require File.dirname(__FILE__) + '/../spec_helper'

describe TwilioRequestsController do
  let(:vendor) { Vendor.create!(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker', :help_text => 'Help me!') }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  before do
    sign_in user
  end

  context "#create with an incorrect account_id" do
    before do
      post :create, twilio_request_params('HELP ', "NO THIS IS WRONG")
    end
    it "should respond with unprocessable_entity" do
      response.response_code.should == 422
    end
  end
  
  context "#create with garbage" do
    before do
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
