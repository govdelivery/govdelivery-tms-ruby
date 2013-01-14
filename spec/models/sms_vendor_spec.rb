require 'spec_helper'

describe SmsVendor do
  let(:vendor) { create_sms_vendor }
  let(:account) { create_account(sms_vendor: vendor) }
  let(:from) { '+12223334444' }
  subject { vendor }

  describe "when valid" do
    it { vendor.valid?.should == true }
  end

  [:name, :username, :password, :help_text, :stop_text, :from].each do |field|
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

  [:help_text, :stop_text].each do |field|
    describe "when #{field} is too long" do
      before { vendor.send("#{field}=", "W"*161) }
      it { vendor.valid?.should == false }
    end
  end

  describe '#create_keyword!' do
    it 'creates a keyword' do
      expect { vendor.create_keyword!(:account => account, :name => 'foobar') }.to change { vendor.keywords.count }.by 1
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

    it 'calls stop on accounts when :stop? => true' do
      vendor.expects(:accounts).returns([account])
      account.expects(:stop).with(:from => from)
      vendor.receive_message!(:from => from, :body => 'msg', :stop? => true)
    end

    it 'blacklists number when :stop? => true' do
      vendor.stubs(:accounts).returns([])
      expect {
        vendor.receive_message!(:from => from, :body => 'msg', :stop? => true)
      }.to change { vendor.stop_requests.count }.by 1
    end
  end
end
