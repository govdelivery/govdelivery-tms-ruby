require 'spec_helper'

describe FromAddress do
  let(:vendor) { create_email_vendor }
  let(:account) { vendor.accounts.create(:name => 'name') }

  context 'with account and email' do
    subject{account.build_from_address(:email=>'hey@dude.com')}
    it{should be_valid}
  end

  context 'with no email' do
    subject { account.build_from_address }
    it { should_not be_valid }
  end
end
