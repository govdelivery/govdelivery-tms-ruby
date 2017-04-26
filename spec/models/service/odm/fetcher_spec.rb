require 'spec_helper'
require 'rails_helper'
require 'ostruct'

if defined?(JRUBY_VERSION)
  java_import com.govdelivery.tms.tmsextended.ActivityRequest
end

class LocalStruct < OpenStruct
  # Kernel#open messes us up so need to deal with it outside of OpenStruct
  def open(*args)
    ['event'] * 5
  end
end

describe Service::Odm::Fetcher do
  it 'only allows real methods' do
    expect {Service::Odm::Fetcher.new(:invalid, 'creds', nil, 1000)}.to raise_error(RuntimeError)
  end
  it "doesn't allow a batch_size of zero" do
    expect {Service::Odm::Fetcher.new(:delivery, 'creds', nil, 0)}.to raise_error(RuntimeError)
  end
  describe 'with a service that raises' do
    it 'allows service exceptions to bubble' do
      service = mock
      service.expects(:delivery_activity_since).raises(Exception.new('foo'))
      expect {Service::Odm::Fetcher.new(:delivery, 'creds', service, 1000).fetch('a sequence')}.to raise_error('foo')
    end
  end
  [:delivery, :click, :open].each do |type|
    describe "with a service that returns #{type}_activity_batch" do
      let(:activity_batch) {LocalStruct.new(type => ['event'] * 5, next_sequence: 'the next one')}

      let(:activity_request) do
        req = LocalStruct.new(max_results: 0)
        ActivityRequest.expects(:new).returns(req)
        req
      end

      let(:service) do
        service = mock
        service.expects("#{type}_activity_since").with('creds', activity_request).returns(activity_batch)
        service
      end

      it 'maps activity stuff to a Fetcher::Batch' do
        subject = Service::Odm::Fetcher.new(type, 'creds', service, 1000)

        batch = subject.fetch('a sequence')
        expect(batch.events).to eq(activity_batch.send(type))
        expect(batch.next_sequence).to eq(activity_batch.next_sequence)
      end
      it 'returns the "last" batch when its batch_size is more than the number of events returned from ODM' do
        number_of_events_returned_from_odm = activity_batch.send(type).size
        batch = Service::Odm::Fetcher.new(type, 'creds', service, number_of_events_returned_from_odm + 1).fetch('a sequence')

        expect(batch.has_more?).to be false
      end
      it 'returns a batch that "has_more" when its @batch_size == number of events returned from ODM' do
        number_of_events_returned_from_odm = activity_batch.send(type).size
        batch = Service::Odm::Fetcher.new(type, 'creds', service, number_of_events_returned_from_odm).fetch('a sequence')

        expect(batch.has_more?).to be true
      end
      it 'sets ActivityRequest#max_results to its batch_size' do
        batch_size = 3158
        activity_request.expects(:max_results=).at_least_once.with(batch_size)
        Service::Odm::Fetcher.new(type, 'creds', service, batch_size).fetch('a sequence')
      end
    end
  end
end
