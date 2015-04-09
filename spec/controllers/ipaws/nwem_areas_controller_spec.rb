require 'rails_helper'

if defined? JRUBY_VERSION

  describe IPAWS::NwemAreasController do
    let(:ipaws_credentials) do
      {
        ipaws_user_id: 12_345,
        ipaws_cog_id: 'IPAWS_OPEN_12345',
        ipaws_jks_base64: 'AAAAAAA',
        ipaws_public_password: 'alligator',
        ipaws_private_password: ')W*#$*SLDFJK#H$#'
      }
    end

    let(:ipaws_response) do
      [{ 'subParaListItem' =>            [{ 'countyName' => 'Arlington' },
                                          { 'geoType' => 'C' },
                                          { 'stateCd' => 'VA' },
                                          { 'stateFips' => '51' },
                                          { 'stateName' => 'Virginia' },
                                          { 'zoneCd' => '054' },
                                          { 'zoneName' => 'Arlington/Falls Church/Alexandria' }],
         'countyFipsCd' => '51013' },
       { 'subParaListItem' =>          [{ 'countyName' => 'City of Alexandria' },
                                        { 'geoType' => 'C' },
                                        { 'stateCd' => 'VA' },
                                        { 'stateFips' => '51' },
                                        { 'stateName' => 'Virginia' },
                                        { 'zoneCd' => '054' },
                                        { 'zoneName' => 'Arlington/Falls Church/Alexandria' }],
         'countyFipsCd' => '51510' }]
    end

    before(:each) do
      IPAWS::Vendor::IPAWSClient.any_instance.stubs(:getNWEMAuxData).returns(ipaws_response)
    end

    describe 'GET :index' do
      it 'returns NWEM area data from IPAWS/FEMA' do
        user = create :user, account: create(:account, ipaws_vendor: create(:ipaws_vendor))
        sign_in user
        get :index, { format: :json }.merge(ipaws_credentials)
        expect(response.response_code).to eq(200)
        expect(response.body).to be_present
        data = JSON.parse(response.body)
        expect(data).to be_present
      end

      it 'responds with 403 (forbidden) if no IPAWS vendor' do
        user = create :user, account: create(:account, ipaws_vendor: nil)
        sign_in user
        get :index, { format: :json }.merge(ipaws_credentials)
        expect(response.response_code).to eq(403)
      end
    end
  end

end
