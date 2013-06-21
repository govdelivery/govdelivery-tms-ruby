require 'spec_helper'
if defined?(JRUBY_VERSION)

  describe Odm::TmsExtendedStatisticsWorker do
    let(:worker) { Odm::TmsExtendedStatisticsWorker.new }

    let(:service_stub) { stub(:delivery_events => delivery_events)}
    let(:delivery_events) { [stub(:recipient_id => "not_numeric", :message_id => "foo", :address => "hey@bob.evotest.com")] }
    
    let(:vendor) { stub(:recipients => stub(:incomplete => stub(:find => nil)))}

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
  end
end