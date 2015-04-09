require 'rails_helper'
if defined?(JRUBY_VERSION)

  describe Odm::TmsExtendedStatisticsWorker do
    before do
      subject.stubs(:sent_at).returns(Time.zone.now)
    end

    let(:worker) { subject }

    let(:service_stub) { stub(delivery_events: delivery_events) }
    let(:delivery_events) { [stub(recipient_id: 'not_numeric', message_id: 'foo', address: 'hey@bob.evotest.com')] }

    let(:vendor) { stub(recipients: stub(incomplete: stub(find: nil))) }

    it 'should not bomb when given non-numeric recipient_id' do
      worker.service = service_stub
      expect { worker.process_vendor(vendor) }.to_not raise_error
    end

    it 'should not bomb when ActiveRecord::RecordNotFound is raised' do
      worker.service = service_stub
      worker.stubs(:parse_recipient_id).returns(43)
      vendor.recipients.incomplete.expects(:find).with(43).raises(ActiveRecord::RecordNotFound)
      expect { worker.process_vendor(vendor) }.to_not raise_error
    end

    # is this breaking ci ?
    # it 'askes delivery_event for sent_at' do
    #   java_import org.joda.time.DateTime
    #   subject.unstub(:sent_at)
    #   subject.sent_at(stub('delivery_event', at: org.joda.time.Time.zone.now )).should be_kind_of(Time)
    # end

    it 'should pass error_message to recipient.failed!() if delivered is false' do
      worker.update_recipient(mock('recipient', failed!: anything),
                              mock('delivery_event', delivered?: false, value: 'oops'))
    end

    context 'odm throws error' do
      let(:service)  { mock('Service::Odm::EventService') }

      before do
        worker.service = service
        # mock database fetch of email vendors
        vendor = stub('email_vendor')
        find_each = mock
        find_each.expects(:find_each).yields(vendor)
        EmailVendor.expects(:tms_extended).returns(find_each)
      end

      it 'should catch Throwable and throw Ruby Exception' do
        service.expects(:delivery_events).raises(Java.java.lang::Exception.new('hello Exception'))

        exception_check(worker, 'hello Exception')
      end

      it 'should catch TMSFault and throw Ruby Exception' do
        service.expects(:delivery_events).raises(Java::ComGovdeliveryTmsTmsextended::TMSFault.new('hello TMSFault', nil))

        exception_check(worker, 'ODM Error: hello TMSFault')
      end
    end
  end
end
