require File.expand_path('../../../../../app/models/service/odm/fetcher', __FILE__)
require File.expand_path('../../../../little_spec_helper', __FILE__)
require 'ostruct'

module Service
  module Odm
    if defined?(JRUBY_VERSION)
      require 'lib/tms_extended.jar'
      java_import com.govdelivery.tms.tmsextended.ActivityRequest
    else
      ActivityRequest = Struct.new(:max_results, :sequence)
    end
    describe Fetcher do
      it "only allows real methods" do
        ->{Fetcher.new(:invalid, 'creds', nil, 1000)}.should raise_error
      end
      it "doesn't allow a batch_size of zero" do
        ->{Fetcher.new(:delivery, 'creds', nil, 0)}.should raise_error
      end
      describe 'with a service that raises' do
        it 'allows service exceptions to bubble' do
          service = mock
          service.expects(:delivery_activity_since).raises(Exception.new('foo'))
          ->{Fetcher.new(:delivery, 'creds', service, 1000).fetch('a sequence')}.should raise_error
        end
      end
      [:open, :delivery, :click].each do |type|
        describe "with a service that returns #{type}_activity_batch" do
          let(:activity_batch) {
            OpenStruct.new(type => ['event'] * 5, :next_sequence => 'the next one')
          }

          let(:activity_request) {
            req = OpenStruct.new(:max_results => 0)
            ActivityRequest.expects(:new).returns(req)
            req
          }

          let(:service) {
            service = mock
            service.expects("#{type}_activity_since").with('creds', activity_request).returns(activity_batch)
            service
          }

          it 'maps activity stuff to a Fetcher::Batch' do
            batch = Fetcher.new(type, 'creds', service, 1000).fetch('a sequence')

            batch.events.should == activity_batch.send(type)
            batch.next_sequence.should == activity_batch.next_sequence
          end
          it 'returns the "last" batch when its batch_size is more than the number of events returned from ODM' do
            number_of_events_returned_from_odm = activity_batch.send(type).size
            batch = Fetcher.new(type, 'creds', service, number_of_events_returned_from_odm + 1).fetch('a sequence')

            batch.has_more?.should be_false
          end
          it 'returns a batch that "has_more" when its @batch_size == number of events returned from ODM' do
            number_of_events_returned_from_odm = activity_batch.send(type).size
            batch = Fetcher.new(type, 'creds', service, number_of_events_returned_from_odm).fetch('a sequence')

            batch.has_more?.should be_true
          end
          it 'sets ActivityRequest#max_results to its batch_size' do
            batch_size = 3158
            activity_request.expects(:max_results=).at_least_once.with(batch_size)
            Fetcher.new(type, 'creds', service, batch_size).fetch('a sequence')
          end
        end
      end
    end
  end
end

