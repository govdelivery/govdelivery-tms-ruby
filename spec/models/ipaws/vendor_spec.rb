require 'spec_helper'

describe IPAWS::Vendor do

  it { should have_many(:accounts) }

  it { should validate_presence_of(:cog_id) }
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:public_password_encrypted) }
  it { should validate_presence_of(:private_password_encrypted) }
  it { should validate_presence_of(:jks) }

  it 'encrypts the public password' do
    vendor = build :ipaws_vendor, public_password: nil
    vendor.public_password.should be_nil
    vendor.public_password_encrypted.should be_nil
    vendor.public_password = 'foobar'
    vendor.public_password_encrypted.should be_present
    vendor.public_password_encrypted.should_not == vendor.public_password
    vendor.public_password.should == 'foobar'
    vendor.save!
    vendor.reload
    vendor.public_password_encrypted.should be_present
    vendor.public_password_encrypted.should_not == vendor.public_password
    vendor.public_password.should == 'foobar'
  end

  it 'encrypts the private password' do
    vendor = build :ipaws_vendor, private_password: nil
    vendor.private_password.should be_nil
    vendor.private_password_encrypted.should be_nil
    vendor.private_password = 'foobar'
    vendor.private_password_encrypted.should be_present
    vendor.private_password_encrypted.should_not == vendor.private_password
    vendor.private_password.should == 'foobar'
    vendor.save!
    vendor.reload
    vendor.private_password_encrypted.should be_present
    vendor.private_password_encrypted.should_not == vendor.private_password
    vendor.private_password.should == 'foobar'
  end

  describe '#client' do
    it 'returns an IPAWS client object' do
      vendor = build :ipaws_vendor
      vendor.client.should be_present
    end
  end

  describe '#ack' do
    let(:raw_response) do
      [{"ACK"=>"PONG"}]
    end
    it 'returns an acknowledgement' do
      subject.client.stubs(:getAck).returns(raw_response)
      subject.ack.should == raw_response
    end
  end

  describe '#got_profile' do
    let(:raw_response) do
      [{"cogid"=>"120082"},
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
       {"subParaListItem"=>
         [{"ALL"=>"FRW"},
          {"ALL"=>"SVR"},
          {"ALL"=>"SPW"},
          {"ALL"=>"LAE"},
          {"ALL"=>"CAE"},
          {"ALL"=>"WSW"},
          {"ALL"=>"CEM"}],
        "eventCodes"=>nil},
       {"subParaListItem"=>[{"SAME"=>"039035"}], "geoCodes"=>nil}]
    end
    it 'returns the cog profile' do
      subject.client.stubs(:getCOGProfile).returns(raw_response)
      subject.cog_profile.should == raw_response
    end
  end

  describe '#post_cap' do
    let(:raw_response) do
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
          {"STATUS"=>"Ack"}]}]
    end
    it 'converts symbol keys to strings' do
      subject.client.expects(:postCAP).with({'key' => 'value'}).returns(raw_response)
      subject.post_cap({key: 'value'}).should == raw_response
    end
  end

  describe '#nwem_cog_authorization' do
    let(:raw_response) do 
      [{"cogid"=>"true"}]
    end
    it 'returns the raw response from FEMA' do
      subject.client.stubs(:isCogAuthorized).returns(raw_response)
      subject.nwem_cog_authorization.should == raw_response
    end
  end

  describe '#nwem_auxilary_data' do
    let(:raw_response) do 
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
    end
    it 'returns the raw response from FEMA' do
      subject.client.stubs(:getNWEMAuxData).returns(raw_response)
      subject.nwem_auxilary_data.should == raw_response
    end
  end

end