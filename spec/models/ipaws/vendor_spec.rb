require 'rails_helper'

describe IPAWS::Vendor do
  before do
    com.govdelivery.ipaws.IPAWSClient.__persistent__ = true if defined?(JRUBY_VERSION)
  end

  it { is_expected.to have_many(:accounts) }

  it { is_expected.to validate_presence_of(:cog_id) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:public_password_encrypted) }
  it { is_expected.to validate_presence_of(:private_password_encrypted) }
  it { is_expected.to validate_presence_of(:jks) }

  it 'encrypts the public password' do
    vendor = build :ipaws_vendor, public_password: nil
    expect(vendor.public_password).to be_nil
    expect(vendor.public_password_encrypted).to be_nil
    vendor.public_password = 'foobar'
    expect(vendor.public_password_encrypted).to be_present
    expect(vendor.public_password_encrypted).not_to eq(vendor.public_password)
    expect(vendor.public_password).to eq('foobar')
    vendor.save!
    vendor.reload
    expect(vendor.public_password_encrypted).to be_present
    expect(vendor.public_password_encrypted).not_to eq(vendor.public_password)
    expect(vendor.public_password).to eq('foobar')
  end

  it 'encrypts the private password' do
    vendor = build :ipaws_vendor, private_password: nil
    expect(vendor.private_password).to be_nil
    expect(vendor.private_password_encrypted).to be_nil
    vendor.private_password = 'foobar'
    expect(vendor.private_password_encrypted).to be_present
    expect(vendor.private_password_encrypted).not_to eq(vendor.private_password)
    expect(vendor.private_password).to eq('foobar')
    vendor.save!
    vendor.reload
    expect(vendor.private_password_encrypted).to be_present
    expect(vendor.private_password_encrypted).not_to eq(vendor.private_password)
    expect(vendor.private_password).to eq('foobar')
  end

  describe '#client' do
    it 'returns an IPAWS client object' do
      vendor = build :ipaws_vendor
      expect(vendor.client).to be_present
    end
  end

  describe '#ack' do
    let(:ipaws_response) do
      [{"ACK"=>"PONG"}]
    end
    it 'returns an acknowledgement' do
      ipaws_response = [{"ACK"=>"PONG"}]
      xact_response = { "ACK" => "PONG" }
      subject.client.stubs(:getAck).returns(ipaws_response)
      expect(subject.ack).to eq(xact_response)
    end
  end

  describe '#cog_profile' do
    it 'returns the cog profile, flattened' do
      ipaws_response = [
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
      xact_response = {
        "cogid"=>"120082",
        "name"=>"GovDelivery",
        "description"=>"GovDelivery",
        "categoryName"=>"IPAWS-OPEN",
        "organizationName"=>"CIV",
        "cogEnabled"=>"Y",
        "caeAuthorized"=>"Y",
        "caeCmasAuthorized"=>"Y",
        "eanAuthorized"=>"N",
        "allEventCode"=>"N",
        "allGeoCode"=>"N",
        "easAuthorized"=>"Y",
        "cmasAlertAuthorized"=>"Y",
        "cmamTextAuthorized"=>"Y",
        "publicAlertAuthorized"=>"Y",
        "broadcastAuthorized"=>"N",
        "email"=>"joe.bloom@govdelivery.com",
        "eventCodes" => [
          {"ALL"=>"FRW"},
          {"ALL"=>"SVR"},
          {"ALL"=>"SPW"},
          {"ALL"=>"LAE"},
          {"ALL"=>"CAE"},
          {"ALL"=>"WSW"},
          {"ALL"=>"CEM"}
        ],
        "geoCodes" => [
          {"SAME"=>"039035"}
        ]
      }
      subject.client.stubs(:getCOGProfile).returns(ipaws_response)
      expect(subject.cog_profile).to eq(xact_response)
    end
    it 'converts eventCodes or geoCodes to arrays only when present' do
      ipaws_response = [
        {"cogid"=>"120082"},
        {"name"=>"GovDelivery"},
        {"description"=>"GovDelivery"},
        {"categoryName"=>"IPAWS-OPEN"},
        {"organizationName"=>"CIV"},
        {"cogEnabled"=>"Y"},
        {"caeAuthorized"=>"Y"},
        {"caeCmasAuthorized"=>"Y"},
        {"eanAuthorized"=>"N"},
        {"allEventCode"=>"Y"},
        {"allGeoCode"=>"Y"},
        {"easAuthorized"=>"Y"},
        {"cmasAlertAuthorized"=>"Y"},
        {"cmamTextAuthorized"=>"Y"},
        {"publicAlertAuthorized"=>"Y"},
        {"broadcastAuthorized"=>"N"},
        {"email"=>"joe.bloom@govdelivery.com"}
      ]
      xact_response = {
        "cogid"=>"120082",
        "name"=>"GovDelivery",
        "description"=>"GovDelivery",
        "categoryName"=>"IPAWS-OPEN",
        "organizationName"=>"CIV",
        "cogEnabled"=>"Y",
        "caeAuthorized"=>"Y",
        "caeCmasAuthorized"=>"Y",
        "eanAuthorized"=>"N",
        "allEventCode"=>"Y",
        "allGeoCode"=>"Y",
        "easAuthorized"=>"Y",
        "cmasAlertAuthorized"=>"Y",
        "cmamTextAuthorized"=>"Y",
        "publicAlertAuthorized"=>"Y",
        "broadcastAuthorized"=>"N",
        "email"=>"joe.bloom@govdelivery.com"
      }
      subject.client.stubs(:getCOGProfile).returns(ipaws_response)
      expect(subject.cog_profile).to eq(xact_response)
    end
  end

  describe '#post_alert' do
    let(:ipaws_response) do
      [{"identifier"=>"CAP12-TEST-1397743203"},
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
          {"STATUSITEMID"=>"501"},
          {"ERROR"=>"N"},
          {"STATUS"=>"message-not-disseminated-as-EAS"},
          {"CHANNELNAME"=>"CMAS"},
          {"STATUSITEMID"=>"600"},
          {"ERROR"=>"N"},
          {"STATUS"=>"Ack"},
          {"CHANNELNAME"=>"PUBLIC"},
          {"STATUSITEMID"=>"800"},
          {"ERROR"=>"N"},
          {"STATUS"=>"Ack"}]},
       {"subParaListItem"=>
            [{"CHANNELNAME"=>"sendinggatewayid"},
             {"STATUSITEMID"=>10},
             {"ERROR"=>"N"},
             {"STATUS"=>"Ack"}]}]
     end
    let(:xact_response) do
      {
        "identifier"=>"CAP12-TEST-1397743203",
        "statuses"=> [
          {
            "CHANNELNAME"=>"CAPEXCH",
            "STATUSITEMID"=>"200",
            "ERROR"=>"N",
            "STATUS"=>"Ack"
          },
          {
            "CHANNELNAME"=>"CAPEXCH",
            "STATUSITEMID"=>"202",
            "ERROR"=>"N",
            "STATUS"=>"alert-signature-is-valid"
          },
          {
            "CHANNELNAME"=>"IPAWS",
            "STATUSITEMID"=>"300",
            "ERROR"=>"N",
            "STATUS"=>"Ack"
          },
          {
            "CHANNELNAME"=>"NWEM",
            "STATUSITEMID"=>"401",
            "ERROR"=>"N",
            "STATUS"=>"message-not-disseminated-as-NWEM"
          },
          {
            "CHANNELNAME"=>"EAS",
            "STATUSITEMID"=>"501",
            "ERROR"=>"N",
            "STATUS"=>"message-not-disseminated-as-EAS"
          },
          {
            "CHANNELNAME"=>"CMAS",
            "STATUSITEMID"=>"600",
            "ERROR"=>"N",
            "STATUS"=>"Ack"
          },
          {
            "CHANNELNAME"=>"PUBLIC",
            "STATUSITEMID"=>"800",
            "ERROR"=>"N",
            "STATUS"=>"Ack"
          },
          {
            "CHANNELNAME"=>"sendinggatewayid",
            "STATUSITEMID"=>10,
            "ERROR"=>"N",
            "STATUS"=>"Ack"
          }
        ]
      }
    end
    it 'converts symbol keys to strings' do
      subject.client.expects(:postCAP).with({'key' => 'value'}).returns(ipaws_response)
      subject.post_alert({key: 'value'})
    end
    it 'flattens response and groups statuses in groups of 4 with key statuses' do
      subject.client.stubs(:postCAP).returns(ipaws_response)
      expect(subject.post_alert({key: 'value'})).to eq(xact_response)
    end
  end

  describe '#nwem_cog_authorization' do
    it 'returns the status as a single hash' do
      subject.client.stubs(:isCogAuthorized).returns([{"cogid"=>"true"}])
      expect(subject.nwem_cog_authorization).to eq({"cogid"=>"true"})
    end
  end

  describe '#nwem_areas' do
    it 'Flattens each area item from getNWEMAuxData into a single hash' do
      ipaws_response = 
        [{"subParaListItem"=>
           [{"countyName"=>"Arlington"},
            {"geoType"=>"C"},
            {"stateCd"=>"VA"},
            {"stateFips"=>"51"},
            {"stateName"=>"Virginia"},
            {"zoneCd"=>"054"},
            {"zoneName"=>"Arlington/Falls Church/Alexandria"}],
          "countyFipsCd"=>"51013"},
         {"subParaListItem"=>
           [{"countyName"=>"City of Alexandria"},
            {"geoType"=>"C"},
            {"stateCd"=>"VA"},
            {"stateFips"=>"51"},
            {"stateName"=>"Virginia"},
            {"zoneCd"=>"054"},
            {"zoneName"=>"Arlington/Falls Church/Alexandria"}],
          "countyFipsCd"=>"51510"}]
      xact_response = [
        {
          "countyFipsCd"=>"51013",
          "countyName"=>"Arlington",
          "geoType"=>"C",
          "stateCd"=>"VA",
          "stateFips"=>"51",
          "stateName"=>"Virginia",
          "zoneCd"=>"054",
          "zoneName"=>"Arlington/Falls Church/Alexandria"
        },
        {
          "countyFipsCd"=>"51510",
          "countyName"=>"City of Alexandria",
          "geoType"=>"C",
          "stateCd"=>"VA",
          "stateFips"=>"51",
          "stateName"=>"Virginia",
          "zoneCd"=>"054",
          "zoneName"=>"Arlington/Falls Church/Alexandria"
        }
      ]
      subject.client.stubs(:getNWEMAuxData).returns(ipaws_response)
      expect(subject.nwem_areas).to eq(xact_response)
    end
  end

end