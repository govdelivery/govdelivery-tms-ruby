require 'rails_helper'

describe TwilioRequestsController do
  let(:vendor) { create(:sms_vendor) }
  let(:account) { create(:account, :sms_vendor => vendor, name: 'aname', dcm_account_codes: ["ACME", "VANDELAY"]) }

  describe '#create with "STOP"' do
    let(:params) { twilio_request_params('STOP') }
    it 'should respond with created' do
      post :create, params
      expect(response.response_code).to eq(201)
    end
    it 'should respond with stop text' do
      post :create, params
      expect(assigns(:response).response_text).to eq(Service::Keyword::DEFAULT_STOP_TEXT)
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
      account.create_command!( 'stop', :params => CommandParameters.new(:dcm_account_codes => ["ACME","VANDELAY"]),
                           :command_type => :dcm_unsubscribe)
      Command.any_instance.expects(:call)
      post :create, params
    end
  end

  describe "#create with garbage" do
    let(:params) { twilio_request_params('garbage') }
    it "should respond with created" do
      post :create, params
      expect(response.response_code).to eq(201)
    end
    it 'should respond with default response text' do
      post :create, params
      expect(assigns(:response).response_text).to eq(Service::Keyword::DEFAULT_HELP_TEXT)
      expect(assigns(:response).response_text).not_to be_nil
    end
    it 'should persist an inbound message' do
      expect{post :create, params}
        .to change{vendor.inbound_messages.count}.by 1
    end
    it 'does not execute any commands' do
      Command.any_instance.expects(:call).never
    end
  end

  describe '#create with "UNSUBSCRIBE"' do
    let(:params) { twilio_request_params('UNSUBSCRIBE') }
    it 'should respond with created' do
      post :create, params
      expect(response.response_code).to eq(201)
    end
    it 'should respond with vendor stop text' do
      post :create, params
      expect(assigns(:response).response_text).to eq(Service::Keyword::DEFAULT_STOP_TEXT)
    end
    it 'should persist an inbound message' do
      expect{post :create, params}.to change{vendor.inbound_messages.count}.by 1
    end
    it 'should execute commands on its accounts' do
      account.create_command!( 'stop',
                               params: build(:unsubscribe_command_parameters),
                               command_type: :dcm_unsubscribe)
      Command.any_instance.expects(:call)
      post :create, params
    end
    it 'should create a stop request' do
      command = account.create_command!( 'stop',
                              params: build(:unsubscribe_command_parameters),
                              command_type: :dcm_unsubscribe)
      expect {
        post :create, params
      }.to change{StopRequest.count }.by(1)
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
