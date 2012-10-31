require 'spec_helper'

describe View::TwilioRequestResponse do
  let(:vendor) { Vendor.new(:help_text => "You have been helped.", :stop_text => "We'll stop now.") }
  let(:response) { View::TwilioRequestResponse.new(:vendor => vendor, :request => "help me") }

  context "when request contains help text" do
    specify { response.response_text.should == vendor.help_text }
    specify { response.stop?.should == false }
    specify { response.help?.should == true }
  end
  
  context "when request contains stop text" do
    before { response.request = " sTop\n" }
    specify { response.response_text.should == vendor.stop_text }
    specify { response.stop?.should == true }
    specify { response.help?.should == false }
  end

  context "when request is empty" do
    before { response.request = "" }
    specify { response.response_text.should == vendor.help_text }
    specify { response.stop?.should == false }
    specify { response.help?.should == true }
  end

  context "when method missing" do
    before { response.vendor = mock(:foobar => :omg_lol) }
    specify { response.foobar.should == :omg_lol }
  end
end
