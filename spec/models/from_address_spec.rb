require 'spec_helper'

describe FromAddress do
  let(:vendor) { create(:email_vendor) }
  let(:account) { create(:account, email_vendor: vendor) }

  context 'when default' do
    before do
      account.from_addresses.create(:is_default => true, :from_email => 'one@example.com')
      account.from_addresses.create(:is_default => true, :from_email => 'two@example.com')
    end
    it 'should only have one default from address' do
      account.from_addresses.where(is_default: true).count.should eq(1)
    end
  end

  context 'with account and all addresses' do
    subject { account.from_addresses.build(:from_email => 'hey@dude.com', :bounce_email => 'bounce@dude.com', :reply_to_email => 'replyto@dude.com') }
    it { should be_valid }
    it 'should use from email for bounce and reply-to' do
      subject.bounce_email.should eq("bounce@dude.com")
      subject.reply_to_email.should eq('replyto@dude.com')
    end
  end

  context 'with account and from_email' do
    subject { account.from_addresses.build(:from_email => 'hey@dude.com') }
    it { should be_valid }
    it 'should use from email for bounce and reply-to' do
      subject.bounce_email.should eq(subject.from_email)
      subject.reply_to_email.should eq(subject.from_email)
    end
  end

  context 'with no from_email' do
    subject { account.from_addresses.build(:bounce_email => 'bounce@dude.com', :reply_to_email => 'replyto@dude.com') }
    it { should_not be_valid }
  end
end
