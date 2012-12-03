require_relative '../../../app/models/view/twilio_request_response'
require_relative '../../little_spec_helper'

describe View::TwilioRequestResponse do
  it 'delegates to vendor' do
    vendor = mock(:foobar => :omg_lol)
    subject.vendor = vendor
    subject.foobar.should == :omg_lol
  end
end
