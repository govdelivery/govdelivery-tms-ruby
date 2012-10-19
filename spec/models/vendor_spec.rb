require 'spec_helper'

describe Vendor do
  before { @vendor = Vendor.new(:name => 'name', :username => 'username', :password => 'secret', :from => 'from') }
  subject { @vendor }

  context "when valid" do
    specify { @vendor.valid?.should == true }
  end
  
  [:name, :username, :password, :from].each do |field|
    context "when #{field} is empty" do
      before { @vendor.send("#{field}=", nil) }
      specify { @vendor.valid?.should == false }
    end

    context "when #{field} is too long" do
      before { @vendor.send("#{field}=", "W"*257) }
      specify { @vendor.valid?.should == false }
    end
  end
end
