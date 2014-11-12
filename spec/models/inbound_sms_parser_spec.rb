# encoding: UTF-8
require 'rails_helper'

describe InboundSmsParser do
  let(:account) { setup_account 'abc', 'xyz' }

  context "given a shared vendor with prefix: 'abc'" do
    context "sms_body: 'abc' yields:" do
      subject{ InboundSmsParser.parse 'abc', account.sms_vendor }
      its(:prefix)     { should eql('abc') }
      its(:keyword)    { should be_instance_of(Keyword) }
      its(:message)    { should be_blank }
      its(:account_id) { should eql(account.id) }
    end

    context "sms_body: 'blah gibberish with CAPS and ٸ unicode' yields:" do
      subject{ InboundSmsParser.parse 'blah gibberish with CAPS and ٸ unicode', account.sms_vendor }
      its(:prefix)     { should be_blank }
      its(:keyword)    { should be_instance_of(Service::Keyword) }
      its(:message)    { should eql('blah gibberish with caps and ٸ unicode') }
      its(:account_id) { should be_blank }
      it "should respond with help" do
        subject.keyword.type.should eql 'help'
      end
    end

  end

  context "given a shared vendor with prefix 'abc' and an account with keyword 'xyz' " do

    context "sms_body: 'abc xyz' yields:" do
      subject{ InboundSmsParser.parse 'abc xyz', account.sms_vendor }
      its(:prefix)     { should eql('abc') }
      its(:keyword)    { should be_instance_of(Keyword) }
      its(:message)    { should be_blank }
      its(:account_id) { should eql(account.id) }
    end

    context "sms_body: 'abc xyz wut' yields:" do
      subject{ InboundSmsParser.parse 'abc xyz wut', account.sms_vendor }
      its(:prefix)     { should eql('abc') }
      its(:keyword)    { should be_instance_of(Keyword) }
      its(:message)    { should eql('wut') }
      its(:account_id) { should eql(account.id) }
    end

    context "sms_body: 'xyz' yields:" do
      subject{ InboundSmsParser.parse 'xyz', account.sms_vendor }
      its(:prefix)     { should be_blank }
      its(:keyword)    { should be_instance_of(Service::Keyword) }
      its(:message)    { should eql('xyz') }
      its(:account_id) { should be_blank }
      it "should respond with help" do
        subject.keyword.type.should eql 'help'
      end
    end

    context "sms_body: 'help I fell down' yields:" do
      subject{ InboundSmsParser.parse 'help I fell down', account.sms_vendor }
      its(:prefix)     { should be_blank }
      its(:keyword)    { should be_instance_of(Service::Keyword) }
      its(:message)    { should eql('i fell down') }
      its(:account_id) { should be_blank }
      it "should respond with help" do
        subject.keyword.type.should eql 'help'
      end
    end

    context "sms_body: 'abc help I fell down' yields:" do
      subject{ InboundSmsParser.parse 'abc help I fell down', account.sms_vendor }
      its(:prefix)     { should eql('abc') }
      its(:keyword)    { should be_instance_of(Service::Keyword) }
      its(:message)    { should eql('i fell down') }
      its(:account_id) { should eql(account.id) }
      it "should respond with help" do
        subject.keyword.type.should eql 'help'
      end
    end

    context "sms_body: 'abc unsubscribe' yields:" do
      subject{ InboundSmsParser.parse 'abc unsubscribe me@you.com', account.sms_vendor }
      its(:prefix)     { should eql('abc') }
      its(:keyword)    { should be_instance_of(Service::Keyword) }
      its(:message)    { should eql('me@you.com') }
      its(:account_id) { should eql(account.id) }
      it "should respond with stop" do
        subject.keyword.type.should eql 'stop'
      end
    end

    context "blank sms_body: ' ' yields:" do
      subject{ InboundSmsParser.parse ' ', account.sms_vendor }
      its(:prefix)     { should eql(nil) }
      its(:keyword)    { should be_instance_of(Service::Keyword) }
      its(:message)    { should be_blank }
      its(:account_id) { should be_blank }
      it "should respond with help" do
        subject.keyword.type.should eql 'help'
      end
    end

  end

  def setup_account prefix, keyword_name
    # account with sms prefix
    create(:account_with_sms, :shared, prefix: prefix).tap do |account|
      # keyword
      create(:keyword, account: account, name: keyword_name)
    end
  end
end
