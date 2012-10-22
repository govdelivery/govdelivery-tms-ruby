require 'spec_helper'

describe Message do
  before do
    vendor = Vendor.create!(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker')
    account = vendor.accounts.create!(:name => 'name')
    @user = account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop")
    @message = @user.messages.build(:short_body => 'short body')
  end
  
  subject { @message }

  context "when valid" do
    specify { @message.valid?.should == true }
  end
  
  context "when short body is empty" do
    before { @message.short_body = nil }
    specify { @message.valid?.should == false }
  end

  context "when short body is not empty" do
    before { @message.short_body = "A"*160 }
    specify { @message.save.should == true }
  end

  context "when short body is too long" do
    before { @message.short_body = "A"*161 }
    specify { @message.valid?.should == false }
  end

  context "accepts nested attributes for recipients" do
    before { @message = @user.messages.build(:short_body => "A"*160, :recipients_attributes => [{:phone => "6515551212"}]) }
    specify { @message.valid?.should == true }
    it { should have(1).recipients }
  end
  
  context "validates recipients before save" do
    before { @message = @user.messages.build(:short_body => "A"*160, :recipients_attributes => [{:phone => "invalid"}]) }
    specify { @message.valid?.should == false }
  end
end