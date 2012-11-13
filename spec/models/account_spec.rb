require 'spec_helper'

describe Account do
  before do
    vendor = Vendor.new
    @account = Account.new(:name => 'name', :vendor => vendor)
  end
  subject { @account }

  context "when valid" do
    specify { @account.valid?.should == true }
  end
  
  context "when name is empty" do
    before { @account.name = nil }
    specify { @account.valid?.should == false }
  end
  
  context "when name too long" do
    before { @account.name = "W"*257 }
    specify { @account.valid?.should == false }
  end

  context "when created" do
    before { @account.save! }
    specify { @account.stop_keyword.should_not be_nil }
  end

  context "calling stop" do
    before do
      @account.save! # a callback will generate the stop keyword
      @from = "123123123"
      Keyword.any_instance.expects(:execute_actions).with(:from => @from)
      @account.stop(@from)
    end
    specify { true }
  end
end
