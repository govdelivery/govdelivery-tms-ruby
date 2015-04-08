require_relative '../../../app/models/view/twilio_request_response'
require 'spec_helper'

describe View::TwilioRequestResponse do
  subject {
    vendor = stub(foobar: :omg_lol)
    View::TwilioRequestResponse.new(vendor, nil)
  }
  it 'delegates to vendor' do
    expect(subject.foobar).to eq(:omg_lol)
  end
  it 'works with rabl' do
    expect(subject.respond_to?(:foobar)).to be true
  end
end
