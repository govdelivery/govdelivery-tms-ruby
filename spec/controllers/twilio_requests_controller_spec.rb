require 'rails_helper'

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
      assigns(:response).response_text.should == Service::Keyword::DEFAULT_STOP_TEXT
    end

    it "responds to 'HELP' with vendor help text" do
      post :create, twilio_request_params('HELP', @vendor)
      response.response_code.should eq(201)
      assigns(:response).response_text.should == Service::Keyword::DEFAULT_HELP_TEXT
    end

    it "responds to: 'GIBBERISH' with account default response text" do
      account = create_account 'pirate', 'plunder', @vendor
      default_keyword = account.default_keyword
      default_keyword.response_text = "Aye! Ye got me booty!"
      default_keyword.save
      post :create, twilio_request_params('GIBBERISH', @vendor)
      response.response_code.should eq(201)
      assigns(:response).response_text.should == "Aye! Ye got me booty!"
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

      context "an account WITHOUT custom stop text, help text, or default response text" do
        it "responds to 'pirate stop' with vendor stop text" do
          post :create, @params.merge('Body' => 'pirate stop')
          assigns(:response).response_text.should eql( Service::Keyword::DEFAULT_STOP_TEXT )
        end
        it "responds to 'pirate help' with vendor help text" do
          post :create, @params.merge('Body' => 'pirate help')
          assigns(:response).response_text.should eql( Service::Keyword::DEFAULT_HELP_TEXT )
        end
        it "responds to 'pirate nothin' with account help text" do
          post :create, @params.merge('Body' => 'pirate nothin')
          assigns(:response).response_text.should be_nil
        end
      end

      context "an account WITH custom stop text, help text, and default response text" do
        before :each do
          stop_keyword = @account.stop_keyword
          stop_keyword.response_text = 'oh sorry'
          stop_keyword.save
          help_keyword = @account.help_keyword
          help_keyword.response_text = 'maybe later'
          help_keyword.save
          default_keyword = @account.default_keyword
          default_keyword.response_text = 'wat'
          default_keyword.save
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
