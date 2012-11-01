require 'spec_helper'

describe Message do
  let(:vendor) { Vendor.create!(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker') }

  before do
    account = vendor.accounts.create!(:name => 'name')
    @user = account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop")
    @message = @user.messages.build(:short_body => 'short body')
  end
  
  subject { @message }

  context "when valid" do
    it { should be_valid }
  end
  
  context "when short body is empty" do
    before { @message.short_body = nil }
    it { should_not be_valid }
  end

  context "when short body is not empty" do
    before { @message.short_body = "A"*160 }
    specify { @message.save.should == true }
  end

  context "when short body is too long" do
    before { @message.short_body = "A"*161 }
    it { should_not be_valid }
  end

  context "accepts nested attributes for recipients" do
    before { @message = @user.messages.build(:short_body => "A"*160, :recipients_attributes => [{:phone => "6515551212", :vendor => vendor}]) }
    it { should be_valid }
    it { should have(1).recipients }
  end
  
  context "validates recipients before save" do
    before { @message = @user.messages.build(:short_body => "A"*160, :recipients_attributes => [{:phone => nil, :vendor => vendor}]) }
    it { should_not be_valid }
  end

  context "create_recipients" do
    before { @message.save }
      
    context "with invalid recipient" do
      before {@message.create_recipients([{:phone => nil}])}
      specify { @message.recipients.first.should_not be_valid }
    end

    context "with valid recipient" do
      before { @message.create_recipients([{:phone => "6093433422"}])}
      specify { @message.recipients.first.should be_valid }
    end
  end
end