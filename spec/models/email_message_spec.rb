require 'spec_helper'

describe EmailMessage do
  let(:vendor) { create_email_vendor }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:email) { user.email_messages.build(:body => 'longggg body', :subject => 'specs before tests') }
  subject { email }

  context "with all attributes" do
    it { should be_valid }
    it 'should set the account' do
      account.should_not be_nil
    end

    context 'and saved' do
      before { email.save! }
      it 'should be able to create recipients' do
        rcpt = email.create_recipients([:email => 'tyler@dudes.com'])
        email.recipients.reload.count.should eq(1)
      end
    end
  end

  [:subject, :body].each do |field|
    context "without #{field}" do
      it 'should not be valid' do
        email.send("#{field}=", nil)
        should_not be_valid
      end
    end
  end

end
