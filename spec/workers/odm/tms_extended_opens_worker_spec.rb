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
      xmlgregorian = stub(:to_gregorian_calendar => stub(:time_in_millis => 1359784800000))
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

    it 'should not bury exceptions from service' do
      Service::Odm::EventService.expects(:open_events).raises Java::ComSunXmlWsWsdlParser::InaccessibleWSDLException.new []

      exception_check(subject, "0 counts of InaccessibleWSDLException.\n")
    end

    context 'odm throws error' do
      let (:service)  { mock('Service::Odm::EventService') }

      it 'should catch Throwable and throw Ruby Exception' do
        Service::Odm::EventService.expects(:open_events).with(@vendor).raises(Java::java::lang::Exception.new("hello Exception"))
  
        exception_check(subject, "hello Exception")
      end

      it 'should catch TMSFault and throw Ruby Exception' do
        Service::Odm::EventService.expects(:open_events).with(@vendor).raises(Java::ComGovdeliveryTmsTmsextended::TMSFault.new("hello TMSFault", nil))

        exception_check(subject, "ODM Error: hello TMSFault")
      end
    end
  end
end
