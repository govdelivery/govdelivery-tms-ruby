require 'spec_helper'

describe TwilioRequestsController do
  let(:vendor) { Vendor.create!(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker', :help_text => 'Help me!') }

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
    it 'executes an action' do
      acct = vendor.accounts.create!(name: 'aname')
      action = acct.add_action!(:params => "ACME,VANDELAY", :action_type => Action::DCM_UNSUBSCRIBE)
      Action.any_instance.expects(:call)
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
    it 'does not execute any actions' do
      Action.any_instance.expects(:call).never
    end
  end

  describe '#create with "SUBSCRIBE NEWS"' do
    let(:params) { twilio_request_params('SUBSCRIBE NEWS') }
    before do
      vendor.create_keyword!(:name => 'subscribe news',
                             :account => create_account(:vendor => vendor))
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
      expect{post :create, params}
        .to change{vendor.inbound_messages.count}.by 1
    end
    it 'executes an action' do
      action = vendor.keywords.first.add_action!(:params => "ACME,VANDELAY", :action_type => Action::DCM_SUBSCRIBE)
      Action.any_instance.expects(:call)
      post :create, params
    end
  end

#   describe "#create with HELP" do
#     before do
#       post :create, params
#     end
#     it "should respond with created" do
#       response.response_code.should == 201
#     end
#     it 'should respond with help text' do
#       assigns(:response).response_text.should == vendor.help_text
#     end
#   end

  def twilio_request_params(body)
    account_id = vendor.username
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
