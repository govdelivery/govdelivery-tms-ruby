require 'spec_helper'

describe TwilioRequestsController do
  let(:vendor) { create(:sms_vendor, :help_text => 'Help me!') }
  let(:account) { create(:account, :sms_vendor => vendor, name: 'aname', dcm_account_codes: ["ACME", "VANDELAY"]) }

  describe '#create with "STOP"' do
    let(:params) { twilio_request_params('STOP') }
    it 'should respond with created' do
      post :create, params
      response.response_code.should == 201
    end
    it 'should respond with stop text' do
      post :create, params
      assigns(:response).response_text.should == vendor.stop_text
    end
    it 'should persist a stop request' do
      expect{post :create, params}
        .to change{vendor.stop_requests.count}.by 1
    end
    it 'should persist an inbound message' do
      expect{post :create, params}
        .to change{vendor.inbound_messages.count}.by 1
    end
    it 'executes a command' do
      account.add_command!(:params => CommandParameters.new(:dcm_account_codes => ["ACME","VANDELAY"]), :command_type => :dcm_unsubscribe)
      Command.any_instance.expects(:call)
      post :create, params
    end
  end

  describe "#create with garbage" do
    let(:params) { twilio_request_params('garbage') }
    it "should respond with created" do
      post :create, params
      response.response_code.should == 201
    end
    it 'should respond with help text' do
      post :create, params
      assigns(:response).response_text.should == vendor.help_text
    end
    it 'should persist an inbound message' do
      expect{post :create, params}
        .to change{vendor.inbound_messages.count}.by 1
    end
    it 'does not execute any commands' do
      Command.any_instance.expects(:call).never
    end
  end

  describe '#create with "SUBSCRIBE"' do
    let(:params) { twilio_request_params('SUBSCRIBE') }
    before do
      vendor.create_keyword!(:name => 'subscribe',
                             :account => account)
    end
    it 'should respond with created' do
      post :create, params
      response.response_code.should == 201
    end
    it 'should respond with empty response' do
      post :create, params
      assigns(:response).response_text.should be_nil
    end
    it 'should persist an inbound message' do
      expect{post :create, params}.to change{vendor.inbound_messages.count}.by 1
    end
    it 'executes a command' do
      vendor.keywords.first.add_command!(:params => CommandParameters.new(dcm_account_codes: ["ACME","VANDELAY"]), :command_type => :dcm_unsubscribe)
      Command.any_instance.expects(:call)
      post :create, params
    end
  end

  def twilio_request_params(body)
    @sid ||= ('0'*34)
    @sid.succ!
    {:format =>"xml" ,
      'SmsSid'=>@sid,
      'AccountSid'=>vendor.username,
      'From'=>'+15551113333',
      'To'=>vendor.from_phone,
      'Body'=>body
    }
  end
end
