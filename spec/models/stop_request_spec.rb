require 'rails_helper'

describe StopRequest do
  let(:vendor) { create(:sms_vendor) }
  let(:stop_request) { vendor.stop_requests.build(:phone => "+16666666666").tap{|s| s.account_id = 1 }}
  let(:dup_stop_request) { vendor.stop_requests.build(:phone => "+16666666666").tap{|s| s.account_id = 1 }}

  [[:phone, 255]].each do |field, length|
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
  end

  context "when vendor is empty" do 
    before { stop_request.vendor = nil }
    specify { stop_request.valid?.should == false }
  end

  context "happy path" do
    specify { stop_request.valid?.should == true}
  end

  context "when unique by phone and vendor and account" do
    before { stop_request.save! ; dup_stop_request.account_id += 1}
    specify { dup_stop_request.should be_valid }
  end
  context "when not unique by phone and vendor and account" do
    before { stop_request.save! }
    specify { dup_stop_request.should be_invalid }
  end
end
