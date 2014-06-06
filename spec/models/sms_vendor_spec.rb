require 'spec_helper'

describe SmsVendor do
  let(:vendor) { create(:sms_vendor) }
  let(:account) { create(:account, sms_vendor: vendor) }
  let(:from) { '+12223334444' }
  subject { vendor }

  describe "when valid" do
    it { vendor.valid?.should == true }
  end

  it 'should not allow duplicate from fields' do
    v2 = create(:sms_vendor)
    v2.from_phone = vendor.from_phone
    v2.should_not be_valid
  end

  [:name, :username, :password, :from, :shared].each do |field|
    describe "when #{field} is empty" do
      before { vendor.send("#{field}=", nil) }
      it { vendor.valid?.should == false }
    end
  end

  [:name, :username, :password].each do |field|
    describe "when #{field} is too long" do
      before { vendor.send("#{field}=", "W"*257) }
      it { vendor.valid?.should == false }
    end
  end

  describe 'a phone number with non-numberic stuff in it' do
    it 'should normalize phone' do
      vendor.from = '(612) 657 8309'
      vendor.save!
      vendor.from.should eq('+16126578309')
    end
    it 'should normalize phone with country code' do
      vendor.from = '+1 (612) 657 8309'
      vendor.save!
      vendor.from.should eq('+16126578309')
    end
    it 'should leave short code alone' do
      vendor.from = '468311'
      vendor.save!
      vendor.from.should eq('468311')
    end
  end

  describe '#create_keyword!' do
    it 'creates a keyword' do
      vendor.accounts << account
      account.keywords.count.should eql(3)
      expect { vendor.create_keyword!(:account => account, :name => 'foobar2') }.to change { vendor.keywords.count }.by 1
      vendor.keywords.count.should eql(8) # 4 special keywords plus 4 account keywords
    end

    it "sets the keyword's vendor to itself" do
      kw = vendor.create_keyword!(:account => account, :name => 'foobar')
      kw.vendor.should == vendor
    end
  end

  describe '#receive_message!' do
    it 'creates an inbound message' do
      vendor.stubs(:accounts).returns([])
      expect { vendor.receive_message!(:from => from, :body => 'msg') }.to change { vendor.inbound_messages.count }.by 1
    end
  end

  describe '#stop!' do
    it 'creates a stop request and calls stop on all accounts' do
      command_params = CommandParameters.new(from: '+15552223323')
      vendor.stubs(:accounts).returns([mock('account1', stop: true), mock('account1', stop: true)])
      expect {
        vendor.stop!(command_params)
      }.to change { vendor.stop_requests.count }.by 1
    end
  end

  describe '#start!' do
    it 'deletes a stop request' do
      phone ='+15552223323'
      vendor.stop_requests.create(phone: phone)
      expect {
        vendor.start!(phone)
      }.to change { vendor.stop_requests.count }.by -1
    end
  end

  describe 'special keywords' do
    subject{ create(:sms_vendor) }
    its(:stop_keyword){ should be_instance_of(Keywords::VendorStop) }
    its(:start_keyword){ should be_instance_of(Keywords::VendorStart) }
    its(:help_keyword){ should be_instance_of(Keywords::VendorHelp) }
    its(:default_keyword){ should be_instance_of(Keywords::VendorDefault) }
  end

end
