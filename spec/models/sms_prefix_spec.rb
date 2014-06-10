require 'spec_helper'

describe SmsPrefix do
  let(:vendor) { create(:sms_vendor) }
  let(:account) { account = vendor.accounts.create!(:name => 'name') }

  context "when prefix is empty" do
    let(:sms_prefix) { account.sms_prefixes.build(:prefix => nil).tap{|f| f.sms_vendor = vendor } }
    it { sms_prefix.should_not be_valid }
  end

  context "when account is empty" do
    let(:sms_prefix) { SmsPrefix.new(:prefix => 'FOO').tap{|f| f.sms_vendor = vendor } }
    it { sms_prefix.should_not be_valid }
  end

  context "when vendor is empty" do
    let(:sms_prefix) { account.sms_prefixes.build(:prefix => 'FOO') }
    it "should derive the id from account" do
      sms_prefix.should be_valid # this has to happen for the next line to work (validation routine)
      sms_prefix.sms_vendor_id.should eq(vendor.id)
    end
  end

  context "duplicate prefixes scoped to vendor" do
    let(:sms_prefix) { account.sms_prefixes.build(:prefix => 'FOO').tap{|f| f.sms_vendor = vendor } }
    before do
      prefix = account.sms_prefixes.build(:prefix => 'FOO')
      prefix.sms_vendor = vendor
      prefix.save!
    end
    it { sms_prefix.should_not be_valid }
  end

  it "should get account for prefix with lowercase or uppercase" do
    sms_prefix = account.sms_prefixes.create!(:prefix => 'FOO').tap{|f| f.update_attribute( :sms_vendor, vendor ) }
    account_id = vendor.sms_prefixes.account_id_for_prefix 'FOO'
    account_id.should eql(account.id)
    account_id2 = vendor.sms_prefixes.account_id_for_prefix 'foo'
    account_id2.should eql(account.id)
  end
end
