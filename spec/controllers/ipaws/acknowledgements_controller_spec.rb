require 'spec_helper'

if defined? JRUBY_VERSION

  describe IPAWS::AcknowledgementsController do

    let(:ipaws_credentials) do
      {
        ipaws_user_id: 12345,
        ipaws_cog_id: 'IPAWS_OPEN_12345',
        ipaws_jks_base64: 'AAAAAAA',
        ipaws_public_password: 'alligator',
        ipaws_private_password: ')W*#$*SLDFJK#H$#'
      }
    end

    let(:sample_ack) do
      { 'ACK' => 'PONG' }
    end

    before(:each) do
      IPAWSClient.any_instance.stubs(:getAck).returns(sample_ack)
    end

    describe "GET show" do
      it 'returns true/false based on IPAWS Service getACK request' do
        user = create :user, account: create(:account, ipaws_enabled: true)
        sign_in user
        get :show, { format: :json }.merge(ipaws_credentials)
        response.response_code.should == 200
        expect(response.body).to be_present
        data = JSON.parse(response.body)
        expect(data).to be == sample_ack
      end

      it 'responds with 403 (forbidden) if no IPAWS vendor' do
        user = create :user, account: create(:account, ipaws_enabled: false)
        sign_in user
        get :show, { format: :json }.merge(ipaws_credentials)
        response.response_code.should == 403
      end

      [:ipaws_user_id, :ipaws_cog_id, :ipaws_jks_base64, :ipaws_public_password, :ipaws_private_password].each do |ipaws_credential|
        it "response with 400 (Bad Request) if #{ipaws_credential} is missing" do
          user = create :user, account: create(:account, ipaws_enabled: true)
          sign_in user
          get :show, { format: :json }.merge(ipaws_credentials).except(ipaws_credential)
          response.response_code.should == 400
        end
      end

    end

  end

end