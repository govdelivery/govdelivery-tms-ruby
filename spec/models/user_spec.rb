require 'spec_helper'

describe User do
  let(:vendor){ create(:sms_vendor) }
  let(:account){vendor.accounts.create(:name => 'name')}
  let(:user){account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop")}
  subject { user }

  context "when valid" do
    specify { subject.valid?.should == true }
    specify { subject.authentication_tokens.count.should == 1 }
  end
  
  context "when email is empty" do
    before { subject.email = nil }
    specify { subject.valid?.should == false }
  end

  context "when email is invalid" do
    before { subject.email = "fooper" }
    specify { subject.valid?.should == false }
  end
  
  context "when account is nil" do
    before { subject.account = nil }
    specify { subject.valid?.should == false }
  end

  it "should find users by token" do
    User.with_token(user.authentication_tokens.first.token).should eq(user)
  end
end
