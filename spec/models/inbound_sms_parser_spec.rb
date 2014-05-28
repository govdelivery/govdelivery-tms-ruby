# encoding: UTF-8
require File.expand_path('../../spec_helper', __FILE__)

describe InboundSmsParser, tx_off: true do
  # the before :all here does not agree with database cleaner's transactions
  # so they are turned off
  before :all do
    @account = setup_prefix 'abc'
    @keyword = setup_keyword @account, 'xyz'
  end

  context "given a shared vendor with prefix: 'abc'" do
    context "sms_body: 'abc' yields:" do
      subject{ InboundSmsParser.parse 'abc', @account.sms_vendor }
      its(:prefix)     { should eql('abc') }
      its(:keyword)    { should be_instance_of(Keywords::AccountDefault) }
      its(:message)    { should be_blank }
      its(:account_id) { should eql(@account.id) }
    end

    context "sms_body: 'blah gibberish with CAPS and ٸ unicode' yields:" do
      subject{ InboundSmsParser.parse 'blah gibberish with CAPS and ٸ unicode', @account.sms_vendor }
      its(:prefix)     { should be_blank }
      its(:keyword)    { should be_instance_of(Keywords::VendorDefault) }
      its(:message)    { should eql('blah gibberish with caps and ٸ unicode') }
      its(:account_id) { should be_blank }
    end

  end

  context "given a shared vendor with prefix 'abc' and an account with keyword 'xyz' " do

    context "sms_body: 'abc xyz' yields:" do
      subject{ InboundSmsParser.parse 'abc xyz', @account.sms_vendor }
      its(:prefix)     { should eql('abc') }
      its(:keyword)    { should be_instance_of(Keyword) }
      its(:message)    { should be_blank }
      its(:account_id) { should eql(@account.id) }
    end

    context "sms_body: 'abc xyz wut' yields:" do
      subject{ InboundSmsParser.parse 'abc xyz wut', @account.sms_vendor }
      its(:prefix)     { should eql('abc') }
      its(:keyword)    { should be_instance_of(Keyword) }
      its(:message)    { should eql('wut') }
      its(:account_id) { should eql(@account.id) }
    end

    context "sms_body: 'xyz' yields:" do
      subject{ InboundSmsParser.parse 'xyz', @account.sms_vendor }
      its(:prefix)     { should be_blank }
      its(:keyword)    { should be_instance_of(Keywords::VendorDefault) }
      its(:message)    { should eql('xyz') }
      its(:account_id) { should be_blank }
    end

    context "sms_body: 'help I fell down' yields:" do
      subject{ InboundSmsParser.parse 'help I fell down', @account.sms_vendor }
      its(:prefix)     { should be_blank }
      its(:keyword)    { should be_instance_of(Keywords::VendorHelp) }
      its(:message)    { should eql('i fell down') }
      its(:account_id) { should be_blank }
    end

    context "sms_body: 'abc help I fell down' yields:" do
      subject{ InboundSmsParser.parse 'abc help I fell down', @account.sms_vendor }
      its(:prefix)     { should eql('abc') }
      its(:keyword)    { should be_instance_of(Keywords::AccountHelp) }
      its(:message)    { should eql('i fell down') }
      its(:account_id) { should eql(@account.id) }
    end

    context "sms_body: 'abc unsubscribe' yields:" do
      subject{ InboundSmsParser.parse 'abc unsubscribe me@you.com', @account.sms_vendor }
      its(:prefix)     { should eql('abc') }
      its(:keyword)    { should be_instance_of(Keywords::AccountStop) }
      its(:message)    { should eql('me@you.com') }
      its(:account_id) { should eql(@account.id) }
    end

  end

  def setup_prefix prefix
    create(:account_with_sms, :shared, prefix: prefix)
  end

  def setup_keyword account, keyword_name
    create(:keyword, account: account, name: keyword_name)
  end

end
