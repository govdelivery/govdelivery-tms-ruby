require 'spec_helper'
if defined?(JRUBY_VERSION)

  describe Odm::TmsExtendedOpensWorker do
    subject { Odm::TmsExtendedOpensWorker.new }

    before do
      # mock database fetch of email vendors
      @vendor = stub('email_vendor')
      find_each = mock
      find_each.expects(:find_each).yields(@vendor)
      EmailVendor.expects(:tms_extended).returns(find_each)
    end

    it 'should process all email vendors' do
      xmlgregorian = stub(:to_gregorian_calendar => stub(:time_in_millis => 1359784800))
      events = [stub('open events', :recipient_id => '1', :address => 'foo@bar.com', :message_id => 'slkdlfk', :at => xmlgregorian, :event_ip => "255.255.255.255")]
      recipient = mock

      # mock service fetch of open events
      Service::Odm::EventService.expects(:open_events).with(@vendor).returns(events)
      
      # mock recipient lookup
      @vendor.expects(:recipients).returns(mock(:find => recipient))

      # mock method to record a open
      recipient.expects(:opened!)

      subject.perform
    end

    it 'should not rescue exceptions from service' do
      Service::Odm::EventService.expects(:open_events).raises Java::ComSunXmlWsWsdlParser::InaccessibleWSDLException.new []
      expect { subject.perform }.to raise_error(Java::ComSunXmlWsWsdlParser::InaccessibleWSDLException)
    end
  end
end
