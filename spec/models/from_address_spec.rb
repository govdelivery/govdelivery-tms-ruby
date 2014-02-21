require 'spec_helper'

describe FromAddress do
  let(:vendor) { create(:email_vendor) }
  let(:account) { create(:account, email_vendor: vendor) }

  it_should_validate_as_email :from_email, :reply_to_email, :bounce_email

  context 'a valid from address' do
    before do
      account.from_addresses.create(:is_default => true, :from_email => 'one@example.com')
    end
    it 'should not allow duplicate default addresses' do
      account.from_addresses.create(:is_default => true, :from_email => 'two@example.com')
      account.from_addresses.where(is_default: true).count.should eq(1)
    end

    it 'should not allow duplicate from emails' do
      fa = account.from_addresses.create(:from_email => 'one@example.com')
      fa.new_record?.should be_true
      fa.errors[:from_email].should_not be_nil
    end
  end

  context 'with account and all addresses' do
    subject { account.from_addresses.build(:from_email => 'hey@dude.com', :bounce_email => 'bounce@dude.com', :reply_to_email => 'replyto@dude.com') }
    it { should be_valid }
    it 'should use from email for bounce and reply-to' do
      subject.bounce_email.should eq("bounce@dude.com")
      subject.errors_to.should    eq("bounce@dude.com")

      subject.reply_to_email.should eq('replyto@dude.com')
      subject.reply_to.should       eq('replyto@dude.com')
    end
  end

  context 'with account and from_email' do
    subject { account.from_addresses.build(:from_email => 'hey@dude.com') }
    it { should be_valid }
  end

  context 'with no from_email' do
    subject { account.from_addresses.build(
      :bounce_email   => 'bounce@dude.com', 
      :reply_to_email => 'replyto@dude.com'
      ) }
    it { should_not be_valid }
  end
end
