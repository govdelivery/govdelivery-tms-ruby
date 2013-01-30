require 'spec_helper'

describe FromAddress do
  let(:vendor) { create_email_vendor }
  let(:account) { vendor.accounts.create(:name => 'name') }

  context 'with account and from_email' do
    subject { account.build_from_address(:from_email => 'hey@dude.com', :bounce_email => 'bounce@dude.com', :reply_to_email => 'replyto@dude.com') }
    it { should be_valid }
  end

  context 'with no from_email' do
    subject { account.build_from_address(:bounce_email => 'bounce@dude.com', :reply_to_email => 'replyto@dude.com') }
    it { should_not be_valid }
  end
end
