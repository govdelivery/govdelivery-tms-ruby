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

  describe '#post_cap' do
    let(:raw_response) do
      {
        "identifier"=>"CAP12-TEST-1397575726",
        "" => [
          {"CHANNELNAME"=>"CAPEXCH"},
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
          {"STATUS"=>"Ack"}
        ]
      }
    end
    it 'converts symbol keys to strings' do
      subject.client.expects(:postCAP).with({'key' => 'value'}).returns(raw_response)
      subject.post_cap({key: 'value'})
    end
    it 'groups response attributes in groups of four, and places them under the key \'responses\'' do
      subject.client.stubs(:postCAP).returns(raw_response)
      subject.post_cap({}).should == 
      {
        "identifier"=>"CAP12-TEST-1397575726",
        "responses" => [
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
          }
        ]
      }
    end
  end

end