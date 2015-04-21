# encoding: UTF-8
require 'rails_helper'

describe InboundSmsParser do

  context 'given a vendor with one account with a prefix' do
    let(:account) { create(:account_with_sms, prefix: 'foo') }

    context "sms_body: 'foo RAD' yields:" do
      subject { InboundSmsParser.parse 'foo RAD', account.sms_vendor }
      its(:prefix) { should eql('foo') }
      its(:message) { should eql('rad') }
      its(:account_id) { should eql(account.id) }
    end

    context "sms_body: 'RAD' yields:" do
      subject { InboundSmsParser.parse 'RAD', account.sms_vendor }
      its(:prefix) { should be_blank }
      its(:message) { should eql('rad') }
      its(:account_id) { should eql(account.id) }
    end
  end

  context 'given a vendor with two accounts' do
    let(:account) { setup_accounts 'abc', 'xyz' }
    context "given a vendor and prefix: 'abc'" do
      context "sms_body: 'abc' yields:" do
        subject { InboundSmsParser.parse 'abc', account.sms_vendor }
        its(:prefix) { should eql('abc') }
        its(:message) { should be_blank }
        its(:account_id) { should eql(account.id) }
      end

      context "sms_body: 'blah gibberish with CAPS and ٸ unicode' yields:" do
        subject { InboundSmsParser.parse 'blah gibberish with CAPS and ٸ unicode', account.sms_vendor }
        its(:prefix) { should be_blank }
        its(:message) { should eql('blah gibberish with caps and ٸ unicode') }
        its(:account_id) { should be_blank }
        it 'should respond with help' do
          expect(subject.keyword_service.send(:response_text)).to eql Service::Keyword::DEFAULT_HELP_TEXT
        end
      end
    end

    context "given a vendor and prefix 'abc' and an account with keyword 'xyz' " do
      context "sms_body: 'abc xyz' yields:" do
        subject { InboundSmsParser.parse 'abc xyz', account.sms_vendor }
        its(:prefix) { should eql('abc') }
        its(:message) { should be_blank }
        its(:account_id) { should eql(account.id) }
      end

      context "sms_body: 'abc xyz wut' yields:" do
        subject { InboundSmsParser.parse 'abc xyz wut', account.sms_vendor }
        its(:prefix) { should eql('abc') }
        its(:message) { should eql('wut') }
        its(:account_id) { should eql(account.id) }
      end

      context "sms_body: 'xyz' yields:" do
        subject { InboundSmsParser.parse 'xyz', account.sms_vendor }
        its(:prefix) { should be_blank }
        its(:message) { should eql('xyz') }
        its(:account_id) { should be_blank }
        it 'should respond with help' do
          expect(subject.keyword_service.send(:response_text)).to eql Service::Keyword::DEFAULT_HELP_TEXT
        end
      end

      context "sms_body: 'help I fell down' yields:" do
        subject { InboundSmsParser.parse 'help I fell down', account.sms_vendor }
        its(:prefix) { should be_blank }
        its(:message) { should eql('i fell down') }
        its(:account_id) { should be_blank }
        it 'should respond with help' do
          expect(subject.keyword_service.send(:response_text)).to eql Service::Keyword::DEFAULT_HELP_TEXT
        end
      end

      context "sms_body: 'abc help I fell down' yields:" do
        subject { InboundSmsParser.parse 'abc help I fell down', account.sms_vendor }
        its(:prefix) { should eql('abc') }
        its(:message) { should eql('i fell down') }
        its(:account_id) { should eql(account.id) }
        it 'should respond with help' do
          expect(subject.keyword_service.send(:response_text)).to eql Service::Keyword::DEFAULT_HELP_TEXT
        end
      end

      context "sms_body: 'abc unsubscribe' yields:" do
        subject { InboundSmsParser.parse 'abc unsubscribe me@you.com', account.sms_vendor }
        its(:prefix) { should eql('abc') }
        its(:message) { should eql('me@you.com') }
        its(:account_id) { should eql(account.id) }
        it 'should respond with stop' do
          expect(subject.keyword_service.send(:response_text)).to eql Service::Keyword::DEFAULT_STOP_TEXT
        end
      end

      context "blank sms_body: ' ' yields:" do
        subject { InboundSmsParser.parse ' ', account.sms_vendor }
        its(:prefix) { should eql(nil) }
        its(:message) { should be_blank }
        its(:account_id) { should be_blank }
        it 'should respond with help' do
          expect(subject.keyword_service.send(:response_text)).to eql Service::Keyword::DEFAULT_HELP_TEXT
        end
      end
    end
  end

  def setup_accounts(prefix, keyword_name)
    other = create(:account_with_sms, prefix: 'other')
    create(:account_with_sms, prefix: prefix, sms_vendor: other.sms_vendor).tap do |account|
      create(:keyword, account: account, name: keyword_name)
    end
  end
end
