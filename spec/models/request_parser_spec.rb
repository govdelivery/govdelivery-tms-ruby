require 'spec_helper'

describe RequestParser do
  let(:vendor) { create_vendor }
  let(:request_parser) { RequestParser.new(vendor, "help me", "333-333-3333") }

  context "when request contains help text" do
    specify { request_parser.stop?.should == false }
    specify { request_parser.help?.should == true }
  end
  
  context "when request contains stop text" do
    before { request_parser.request_text = " sTop\n" }
    specify { request_parser.stop?.should == true }
    specify { request_parser.help?.should == false }
  end

  context "when request is empty" do
    before { request_parser.request_text = "" }
    specify { request_parser.stop?.should == false }
    specify { request_parser.help?.should == true }
  end

  context "parse! with help" do
    before do 
      vendor.expects(:stop!).never
      request_parser.parse! 
    end
    specify { vendor.inbound_messages.count.should be(1)}
  end

  context "parse! with stop" do
    before do 
      request_parser.request_text = "STOP"
      vendor.expects(:stop!)
      request_parser.parse! 
    end
    specify { vendor.inbound_messages.count.should be(1)}
  end
end
