require 'spec_helper'

describe User do
  before do
    vendor = Vendor.create(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker')
    account = vendor.accounts.create(:name => 'name')
    @user = account.users.create(:email => 'foo@evotest.govdelivery.com')
  end
  subject { @user }

  context "when valid" do
    specify { @user.valid?.should == true }
  end
  
  context "when email is empty" do
    before { @user.email = nil }
    specify { @user.valid?.should == false }
  end

  context "when account is nil" do
    before { @user.account = nil }
    specify { @user.valid?.should == false }
  end
end
