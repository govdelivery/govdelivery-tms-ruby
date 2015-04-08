require File.expand_path('../../../../../app/models/service/odm/event_iterator', __FILE__)
require 'spec_helper'

module Service
  module Odm
    TestBatch = Struct.new(:events, :next_sequence, :has_more) do
      def has_more?
        has_more
      end
    end
    describe EventIterator do
      let(:transactor) { ->(&block){block.call} }
      let(:fetcher) {
        f = mock('fetcher')
        f.stubs(:fetch).returns(TestBatch.new([1,2,3], 'the next one', false))
        f
      }
      let(:sequence) {
        stub('sequence', :sequence => 'a sequence',  :update_sequence! => 'blah')
      }
      subject { EventIterator.new(fetcher, sequence, transactor) }

      it 'gets called in a transaction' do
        batch = nil
        transactor = ->(&block){ batch = block.call }
        EventIterator.new(fetcher, sequence, transactor).each {|event|}
        expect(batch.events).to eq([1,2,3])
      end
      it 'keeps calling #fetch on the fetcher until it does not have more' do
        fetcher.expects(:fetch).twice.returns(TestBatch.new([1,2,3], 'the next one', true)).then.returns(TestBatch.new([4,5,6], nil, false))
        subject.each {|event|}
      end
      it 'updates the sequence with the next one' do
        sequence.expects(:update_sequence!).with('the next one')
        subject.each {|event|}
      end
      it 'yields each event in the batch' do
        events = EventIterator.new(fetcher, sequence, transactor).map {|event| event }
        expect(events).to eq([1,2,3])
      end
    end
  end
end
