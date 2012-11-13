require 'spec_helper'

describe Vendor do
  let(:vendor) { create_vendor }
  let(:account) { create_account(vendor: vendor) }
  let(:from) { '+12223334444' }
  subject { vendor }

  context "when valid" do
    specify { vendor.valid?.should == true }
  end
  
  [:name, :username, :password, :from, :help_text, :stop_text].each do |field|
    context "when #{field} is empty" do
      before { vendor.send("#{field}=", nil) }
      specify { vendor.valid?.should == false }
    end
  end

  [:name, :username, :password, :from].each do |field|  
    context "when #{field} is too long" do
      before { vendor.send("#{field}=", "W"*257) }
      specify { vendor.valid?.should == false }
    end
  end

  [:help_text, :stop_text].each do |field|
    context "when #{field} is too long" do
      before { vendor.send("#{field}=", "W"*161) }
      specify { vendor.valid?.should == false }
    end
  end

  context "calling stop!" do
    before do
      vendor.expects(:accounts).returns([account])
      account.expects(:stop).with(from)
      vendor.stop!(from)
    end
    specify { vendor.stop_requests.where(:phone => from).count.should be(1) }
  end
end
