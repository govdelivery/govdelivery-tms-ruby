require 'rails_helper'

describe AuthenticationToken do
  let(:vendor){ create(:sms_vendor) }
  let(:account){vendor.accounts.create(:name => 'name')}
  let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:other_user) { account.users.create(:email => 'foo2@evotest.govdelivery.com', :password => "schwoop") }
  subject { user.authentication_tokens.first }

  context "when valid" do
    specify { subject.valid?.should == true }
  end
  
  context "when token is empty" do
    before { subject.token = nil }
    specify { subject.valid?.should == false }
  end

  context "when token is not unique" do
    before { subject.token = other_user.authentication_tokens.first.token }
    specify { subject.valid?.should == false }
  end

  context "when user is nil" do
    before { subject.user = nil }
    specify { subject.valid?.should == false }
  end

end
