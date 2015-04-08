require 'rails_helper'

if defined? JRUBY_VERSION

  describe IPAWS::AlertsController do

    let(:ipaws_credentials) do
      {
        ipaws_user_id: 12345,
        ipaws_cog_id: 'IPAWS_OPEN_12345',
        ipaws_jks_base64: 'AAAAAAA',
        ipaws_public_password: 'alligator',
        ipaws_private_password: ')W*#$*SLDFJK#H$#'
      }
    end

    # These sample responses were derived directly from the IPAWS spec PDF.

    let(:ipaws_alert_params) do
      {
        'identifier' => 'CAP12-TEST-11-30-0001',
        'sender' => 'test@open.com',
        'status' => 'Actual',
        'info' => {
          'language' => 'en-US',
          'category' => 'Safety'
        } 
      }
    end

    let(:ipaws_post_cap_response) do
      [{"identifier"=>"ipaws_alerts/3c9cfb43/2014-09-18T17:33:28-04:00"},
       {"subParaListItem"=>
         [{"CHANNELNAME"=>"CAPEXCH"},
          {"STATUSITEMID"=>"200"},
          {"ERROR"=>"N"},
          {"STATUS"=>"Ack"},
          {"CHANNELNAME"=>"CAPEXCH"},
          {"STATUSITEMID"=>"202"},
          {"ERROR"=>"N"},
          {"STATUS"=>"alert-signature-is-valid"},
          {"CHANNELNAME"=>"IPAWS"},
          {"STATUSITEMID"=>"300"},
          {"ERROR"=>"N"},
          {"STATUS"=>"Ack"},
          {"CHANNELNAME"=>"NWEM"},
          {"STATUSITEMID"=>"401"},
          {"ERROR"=>"N"},
          {"STATUS"=>"message-not-disseminated-as-NWEM"},
          {"CHANNELNAME"=>"EAS"},
          {"STATUSITEMID"=>"500"},
          {"ERROR"=>"N"},
          {"STATUS"=>"Ack"},
          {"CHANNELNAME"=>"CMAS"},
          {"STATUSITEMID"=>"600"},
          {"ERROR"=>"N"},
          {"STATUS"=>"Ack"},
          {"CHANNELNAME"=>"PUBLIC"},
          {"STATUSITEMID"=>"801"},
          {"ERROR"=>"N"},
          {"STATUS"=>"message-not-disseminated-as-non-EAS-public"}]},
       {"subParaListItem"=>
            [{"CHANNELNAME"=>"sendinggatewayid"},
             {"STATUSITEMID"=>"10"},
             {"ERROR"=>"N"},
             {"STATUS"=>"Ack"}]}]
    end

    let(:ipaws_post_cap_error_response) do
      [{"identifier"=>"CAP12-TEST-1397743203"},
       {"subParaListItem"=>
         [{"CHANNELNAME"=>"IPAWS"},
          {"STATUSITEMID"=>"307"},
          {"ERROR"=>"Y"},
          {"STATUS"=>"reference-element-invalid"}]}]
    end

    describe "POST create" do

      it 'returns the IPAWS successful response' do
        IPAWS::Vendor::IPAWSClient.any_instance.stubs(:postCAP).returns(ipaws_post_cap_response)
        user = create :user, account: create(:account, ipaws_vendor: create(:ipaws_vendor))
        sign_in user
        post :create, ipaws_credentials.merge(ipaws_alert_params)
        expect(response.response_code).to eq(200)
        expect(response.body).to be_present
        expect(JSON.parse(response.body)).to be_present
      end

      it 'returns the IPAWS error response' do
        IPAWS::Vendor::IPAWSClient.any_instance.stubs(:postCAP).returns(ipaws_post_cap_error_response)
        user = create :user, account: create(:account, ipaws_vendor: create(:ipaws_vendor))
        sign_in user
        post :create, ipaws_credentials.merge(ipaws_alert_params)
        expect(response.response_code).to eq(200)
        expect(response.body).to be_present
        expect(JSON.parse(response.body)).to be_present
      end

      it 'responds with 403 (forbidden) if no IPAWS vendor' do
        user = create :user, account: create(:account, ipaws_vendor: nil)
        sign_in user
        post :create, ipaws_credentials.merge(ipaws_alert_params)
        expect(response.response_code).to eq(403)
      end

    end

  end

end