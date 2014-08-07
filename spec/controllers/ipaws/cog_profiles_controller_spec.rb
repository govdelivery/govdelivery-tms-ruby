require 'rails_helper'

if defined? JRUBY_VERSION

  describe IPAWS::CogProfilesController do

    let(:ipaws_credentials) do
      {
        ipaws_user_id: 12345,
        ipaws_cog_id: 'IPAWS_OPEN_12345',
        ipaws_jks_base64: 'AAAAAAA',
        ipaws_public_password: 'alligator',
        ipaws_private_password: ')W*#$*SLDFJK#H$#'
      }
    end

    let(:ipaws_response) do
      [
        {"cogid"=>"120082"},
        {"name"=>"GovDelivery"},
        {"description"=>"GovDelivery"},
        {"categoryName"=>"IPAWS-OPEN"},
        {"organizationName"=>"CIV"},
        {"cogEnabled"=>"Y"},
        {"caeAuthorized"=>"Y"},
        {"caeCmasAuthorized"=>"Y"},
        {"eanAuthorized"=>"N"},
        {"allEventCode"=>"N"},
        {"allGeoCode"=>"N"},
        {"easAuthorized"=>"Y"},
        {"cmasAlertAuthorized"=>"Y"},
        {"cmamTextAuthorized"=>"Y"},
        {"publicAlertAuthorized"=>"Y"},
        {"broadcastAuthorized"=>"N"},
        {"email"=>"joe.bloom@govdelivery.com"},
        {"eventCodes"=>nil,
          "subParaListItem"=>[
          {"ALL"=>"FRW"},
          {"ALL"=>"SVR"},
          {"ALL"=>"SPW"},
          {"ALL"=>"LAE"},
          {"ALL"=>"CAE"},
          {"ALL"=>"WSW"},
          {"ALL"=>"CEM"}]
        },
        {"geoCodes"=>nil, "subParaListItem"=>[{"SAME"=>"039035"}]}
      ]
    end

    before(:each) do
      IPAWS::Vendor::IPAWSClient.any_instance.stubs(:getCOGProfile).returns(ipaws_response)
    end

    describe "GET :show" do
      it 'returns data from IPAWS/FEMA' do
        user = create :user, account: create(:account, ipaws_vendor: create(:ipaws_vendor))
        sign_in user
        get :show, { format: :json }.merge(ipaws_credentials)
        response.response_code.should == 200
        expect(response.body).to be_present
        data = JSON.parse(response.body)
        data.should be_present
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