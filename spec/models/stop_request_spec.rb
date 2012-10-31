require 'spec_helper'

describe StopRequest do
  let(:vendor) { Vendor.create!(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker') }
  let(:stop_request) { StopRequest.new(:country_code => "1", :phone => "6666666666", :vendor => vendor) }
  
  [[:phone, 255], [:country_code, 4]].each do |field, length|
    context "when #{field} is empty" do
      before { stop_request.send("#{field}=", nil) }
      specify { stop_request.valid?.should == false }
    end

    context "when #{field} is too long" do
      before { stop_request.send("#{field}=", "1"*(length + 1)) }
      specify { stop_request.valid?.should == false }
    end

    context "when #{field} is not too long" do
      before { stop_request.send("#{field}=", "1"*(length - 1)) }
      specify { stop_request.valid?.should == true }
    end

    context "when #{field} is not a number" do
      before { stop_request.send("#{field}=", "WW")}
      specify { stop_request.valid?.should == false }
    end
  end

  context "when vendor is empty" do 
    before { stop_request.vendor = nil }
    specify { stop_request.valid?.should == false }
  end

  context "happy path" do
    specify { stop_request.valid?.should == true}
  end
end
