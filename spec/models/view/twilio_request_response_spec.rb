require_relative '../../../app/models/view/twilio_request_response'
require_relative '../../little_spec_helper'

describe View::TwilioRequestResponse do
  subject {
    vendor = stub(:foobar => :omg_lol)
    View::TwilioRequestResponse.new(vendor, nil)
  }
  it 'delegates to vendor' do
    subject.foobar.should == :omg_lol
  end
  it 'works with rabl' do
    subject.respond_to?(:foobar).should be_true
  end
end
