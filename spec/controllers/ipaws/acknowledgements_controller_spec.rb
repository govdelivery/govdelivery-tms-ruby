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
      IPAWSClient.any_instance.stubs(:ack).returns(sample_ack)
    end

    describe "GET show" do
      it 'returns true/false based on IPAWS Service getACK request' do
        user = create :user, account: create(:account, ipaws_vendor: create(:ipaws_vendor))
        sign_in user
        get :show, { format: :json }.merge(ipaws_credentials)
        response.response_code.should == 200
        expect(response.body).to be_present
        data = JSON.parse(response.body)
        expect(data).to be == sample_ack
      end

      it 'responds with 403 (forbidden) if no IPAWS vendor' do
        user = create :user, account: create(:account, ipaws_vendor: nil)
        sign_in user
        get :show, { format: :json }.merge(ipaws_credentials)
        response.response_code.should == 403
      end

    end

  end

end