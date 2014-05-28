require 'spec_helper'

describe TwilioRequestsController, '#create' do
  # a short_code has been provisioned with twilio
  # a vendor has been provisioned with credentials from twilio
  # AccountSid and SmsSid are added to the request by twilio

  # let(:vendor) { create(:sms_vendor) }
  # let(:response_text) { 'a response!' }
  before :each do |group|
    @vendor = create(:sms_vendor)
  end
  context 'without a prefix' do
    it 'should return 404 on a non-existant AccountSid' do
      post :create, twilio_request_params('HELP ', @vendor).merge('AccountSid' => 'something ridiculous')
      response.response_code.should eq(404)
    end

    it "responds to 'STOP' with vendor stop text" do
      SmsVendor.any_instance.expects(:stop!).with(kind_of(CommandParameters))
      post :create, twilio_request_params('STOP', @vendor)
      response.response_code.should eq(201)
      assigns(:response).response_text.should == @vendor.stop_text
    end

    it "responds to 'HELP' with vendor help text" do
      post :create, twilio_request_params('HELP', @vendor)
      response.response_code.should eq(201)
      assigns(:response).response_text.should == @vendor.help_text
    end

    it "responds to: 'GIBBERISH' with vendor default response text" do
      @vendor.update_attribute :default_response_text, "turn left"
      post :create, twilio_request_params('GIBBERISH', @vendor)
      response.response_code.should eq(201)
      assigns(:response).response_text.should == "turn left"
    end
  end

  context "an account with prefix: pirate" do
    context "a keyword with name: 'plunder' and a forward command without response text " do
      before :each do
        @account = create_account 'pirate', 'plunder', @vendor
        @keyword = @account.keywords.last
        @params  = twilio_request_params('pirate plunder kind of blue by miles davis', @account.sms_vendor)
      end
      it "does not respond" do
        post :create, @params
        assigns(:response).response_text.should be_blank
      end

      context " adding response text: 'ok' to the keyword" do
        # Note: had to set the @keyword var in the :all block for this to work (?)
        it "responds with 'ok'" do
          @keyword.update_attribute( :response_text, 'ok')
          post :create, @params
          assigns(:response).response_text.should eql('ok')
        end
      end

      context "an account WITHOUT stop text, help text, or default response text" do
        it "responds to 'pirate stop' with vendor stop text" do
          post :create, @params.merge('Body' => 'pirate stop')
          assigns(:response).response_text.should eql(@account.sms_vendor.stop_text)
        end
        it "responds to 'pirate help' with vendor help text" do
          post :create, @params.merge('Body' => 'pirate help')
          assigns(:response).response_text.should eql(@account.sms_vendor.help_text)
        end
        it "responds to 'pirate nothin' with account default response text" do
          post :create, @params.merge('Body' => 'pirate nothin')
          assigns(:response).response_text.should eql(@account.sms_vendor.default_response_text)
        end
      end

      context "an account WITH stop text, help text, and default response text" do
        before :each do
          @account.stop_text = 'oh sorry'
          @account.help_text = 'maybe later'
          @account.default_response_text = 'wat'
          @account.save!
        end
        it "responds to 'pirate stop' with account stop text" do
          post :create, @params.merge('Body' => 'pirate stop')
          assigns(:response).response_text.should eql("oh sorry")
        end
        it "responds to 'pirate help' with account help text" do
          post :create, @params.merge('Body' => 'pirate help')
          assigns(:response).response_text.should eql("maybe later")
        end
        it "responds to 'pirate nothin' with account default response text" do
          post :create, @params.merge('Body' => 'pirate nothin')
          assigns(:response).response_text.should eql("wat")
        end
      end
    end
  end

  def create_account prefix, keyword, vendor
    account = create(:account_with_sms, :shared, prefix: prefix, sms_vendor: vendor)
    account.create_command!(keyword, { params: { command_type: :forward,
                                http_method: 'POST',
                                url: 'http://what.cd' },
                              command_type: :forward })
    account.save!
    account
  end


  def twilio_request_params(body, vendor)
    @sid ||= ('0'*34)
    @sid.succ!
    {:format => "xml",
      'SmsSid' => @sid,
      'AccountSid' => vendor.username,
      'From' => vendor.username,
      'To' => vendor.from_phone,
      'Body' => body}
  end
end
