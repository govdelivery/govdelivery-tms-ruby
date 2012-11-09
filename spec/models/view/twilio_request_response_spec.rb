require 'spec_helper'

describe View::TwilioRequestResponse do
  let(:vendor) { Vendor.new(:help_text => "You have been helped.", :stop_text => "We'll stop now.") }
  let(:request_parser) { RequestParser.new(vendor, "help me", '333-444-5555') }
  let(:response) { View::TwilioRequestResponse.new(vendor, request_parser) }

  context "when request contains help text" do
    specify { response.response_text.should == vendor.help_text }
  end
  
  context "when request contains stop text" do
    before { request_parser.request_text = " sTop\n" }
    specify { response.response_text.should == vendor.stop_text }
  end

  context "when request is empty" do
    before { request_parser.request_text = "" }
    specify { response.response_text.should == vendor.help_text }
  end

  context "when method missing" do
    before { request_parser.vendor = mock(:foobar => :omg_lol) }
    specify { response.foobar.should == :omg_lol }
  end
end
