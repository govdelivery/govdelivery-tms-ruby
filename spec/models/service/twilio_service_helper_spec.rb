require_relative '../../../app/models/service/twilio_service_helper'
require_relative '../../../app/models/recipient_status'
require_relative '../../little_spec_helper'

class FooService
  include Service::TwilioServiceHelper
end

describe Service::TwilioServiceHelper do
  let(:service) { FooService.new }
  let(:response) { mock('response', :status => "sending", :sid => "123") }
  let(:recipient) { stub('recipient') }

  describe "completing a recipient" do
    before do
      recipient.expects(:complete!).with(:ack=> '123', :error_message=>'OMG', :status=>RecipientStatus::STATUS_SENDING)
    end
    it 'should set the right fields' do
      service.complete!(recipient, response, "OMG")
    end
  end
end