require 'spec_helper'

describe FromAddress do
  let(:vendor) { create_email_vendor }
  let(:account) { vendor.accounts.create(:name => 'name') }

  context 'with account and all addresses' do
    subject { account.build_from_address(:from_email => 'hey@dude.com', :bounce_email => 'bounce@dude.com', :reply_to_email => 'replyto@dude.com') }
    it { should be_valid }
    it 'should use from email for bounce and reply-to' do
      subject.bounce_email.should eq("bounce@dude.com")
      subject.reply_to_email.should eq('replyto@dude.com')
    end
  end

  context 'with account and from_email' do
    subject { account.build_from_address(:from_email => 'hey@dude.com') }
    it { should be_valid }
    it 'should use from email for bounce and reply-to' do
      subject.bounce_email.should eq(subject.from_email)
      subject.reply_to_email.should eq(subject.from_email)
    end
  end

  context 'with no from_email' do
    subject { account.build_from_address(:bounce_email => 'bounce@dude.com', :reply_to_email => 'replyto@dude.com') }
    it { should_not be_valid }
  end
end
