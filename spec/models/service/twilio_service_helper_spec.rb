require_relative '../../../app/models/service/twilio_service_helper'
require_relative '../../little_spec_helper'

class FooService
  include Service::TwilioServiceHelper
end

describe Service::TwilioServiceHelper do
  let(:service) { FooService.new }
  let(:response) { mock(:status => "sending", :sid => "123") }
  let(:recipient) { Recipient.new }

  describe "completing a recipient" do
    before do
      recipient.expects(:save!)
    end
    it 'should set the right fields' do
      service.complete!(recipient, response, "OMG")

      recipient.status.should eq(Recipient::STATUS_SENDING)
      recipient.ack.should eq('123')
      recipient.error_message.should eq('OMG')
    end
  end
end