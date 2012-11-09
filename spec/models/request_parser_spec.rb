require 'spec_helper'

describe RequestParser do
  let(:vendor) { Vendor.new(:help_text => "You have been helped.", :stop_text => "We'll stop now.") }
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
end
