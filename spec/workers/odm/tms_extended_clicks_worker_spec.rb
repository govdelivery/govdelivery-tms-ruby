require 'rails_helper'
if defined?(JRUBY_VERSION)

  describe Odm::TmsExtendedClicksWorker do
    subject { Odm::TmsExtendedClicksWorker.new }

    before do
      # mock database fetch of email vendors
      @vendor = stub('email_vendor')
      find_each = mock
      find_each.expects(:find_each).yields(@vendor)
      EmailVendor.expects(:tms_extended).returns(find_each)
    end

    it 'should process all email vendors' do
      xmlgregorian = stub(:to_gregorian_calendar => stub(:time_in_millis => 1359784800000))
      events = [stub('click events', :recipient_id => '1', :address => 'foo@bar.com', :message_id => 'slkdlfk', :at => xmlgregorian, :url => "clickonme.com")]
      recipient = mock

      # mock service fetch of click events
      Service::Odm::EventService.expects(:click_events).with(@vendor).returns(events)
      
      # mock recipient lookup
      @vendor.expects(:recipients).returns(mock(:find => recipient))

      # mock method to record a click
      recipient.expects(:clicked!)

      subject.perform
    end

    it 'should not bury exceptions from service' do
      Service::Odm::EventService.expects(:click_events).raises Java::JavaxXmlWs::WebServiceException.new('it happened')

      exception_check(subject, "it happened")
    end

    context 'odm throws error' do
      let (:service)  { mock('Service::Odm::EventService') }

      it 'should catch Throwable and throw Ruby Exception' do
        Service::Odm::EventService.expects(:click_events).with(@vendor).raises(Java::java::lang::Exception.new("hello Exception"))
  
        exception_check(subject, "hello Exception")
      end

      it 'should catch TMSFault and throw Ruby Exception' do
        Service::Odm::EventService.expects(:click_events).with(@vendor).raises(Java::ComGovdeliveryTmsTmsextended::TMSFault.new("hello TMSFault", nil))

        exception_check(subject, "ODM Error: hello TMSFault")
      end
    end
  end
end
