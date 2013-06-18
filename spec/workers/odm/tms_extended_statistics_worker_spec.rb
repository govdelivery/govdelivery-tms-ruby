require 'spec_helper'
if defined?(JRUBY_VERSION)

  describe Odm::TmsExtendedStatisticsWorker do
    let(:worker) { Odm::TmsExtendedStatisticsWorker.new }
    let(:service_stub) { stub(:delivery_events => delivery_events)}
    let(:delivery_events) { [stub(:recipient_id => "not_numeric", :message_id => "foo", :address => "hey@bob.evotest.com")] }

    before do
      worker.service = service_stub
    end

    it 'should handle integer cast exceptions' do
      expect { worker.process_vendor(nil) }.to_not raise_error
    end
  end
end