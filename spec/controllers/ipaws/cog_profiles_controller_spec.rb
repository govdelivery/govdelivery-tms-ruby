require 'spec_helper'

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

    let(:sample_cog_profile) do
      {
        'cogid' => 999, 
        'name' => 'IPAWS Training COG', 
        'description' => 'Operating Group-IPAWS Training', 
        'categoryName' => 'IPAWS-OPEN', 
        'organizationName' => 'CIV', 
        'cogEnabled' => 'Y',
        'caeAuthorized' => 'N',
        'caeCmasAuthorized' => 'N',
        'eanAuthorized' => 'N',
        'allEventCode' => 'N',
        'allGeoCode' => 'N',
        'easAuthorized' => 'N',
        'cmasAlertAuthorized' => 'N',
        'cmamTextAuthorized' => 'N',
        'publicAlertAuthorized' => 'N',
        'broadcastAuthorized' => 'N',
        'email' => 'test@email.com',
        'eventCodes' => [
          { 'ALL' => 'SVR' },
          { 'ALL' => 'SVS' },
          { 'ALL' => 'EVI' },
          { 'ALL' => 'SPW' },
          { 'ALL' => 'ADR' },
          { 'ALL' => 'AVW' },
          { 'ALL' => 'TOE' },
          { 'ALL' => 'FFW' },
          { 'ALL' => 'FRW' },
          { 'ALL' => 'VOW' },
          { 'ALL' => 'BZW' },
          { 'ALL' => 'CDW' },
          { 'ALL' => 'LAE' },
          { 'ALL' => 'TOR' },
          { 'EAS' => 'CAE' },
          { 'EAS' => 'RWT' } ],
        'geoCodes' => [
          { 'SAME' => '051510' } ]
      }
    end

    before(:each) do
      IPAWSClient.any_instance.stubs(:cog_profile).returns(sample_cog_profile)
    end

    describe "GET show" do
      it 'returns profile based on IPAWS Service getCOGProfile request' do
        user = create :user, account: create(:account, ipaws_vendor: create(:ipaws_vendor))
        sign_in user
        get :show, { format: :json }.merge(ipaws_credentials)
        response.response_code.should == 200
        expect(response.body).to be_present
        data = JSON.parse(response.body)
        expect(data).to be == sample_cog_profile
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