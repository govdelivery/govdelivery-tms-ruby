require 'spec_helper'

describe Vendor do
  before { @vendor = Vendor.create(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker') }
  subject { @vendor }

  context "when valid" do
    specify { @vendor.valid?.should == true }
  end
  
  [:name, :username, :password, :from, :help_text, :stop_text].each do |field|
    context "when #{field} is empty" do
      before { @vendor.send("#{field}=", nil) }
      specify { @vendor.valid?.should == false }
    end
  end

  [:name, :username, :password, :from].each do |field|  
    context "when #{field} is too long" do
      before { @vendor.send("#{field}=", "W"*257) }
      specify { @vendor.valid?.should == false }
    end
  end

  [:help_text, :stop_text].each do |field|
    context "when #{field} is too long" do
      before { @vendor.send("#{field}=", "W"*161) }
      specify { @vendor.valid?.should == false }
    end
  end
end
