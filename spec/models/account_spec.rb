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
end
