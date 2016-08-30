require 'rails_helper'
require 'jakety_jak'
describe Analytics::PublisherWorker do
  it 'should not perform when analytics is disabled' do
    Rails.configuration.stubs(:analytics).returns(enabled: false)
    Analytics::PublisherWorker.new.perform({})
  end

  describe 'when analytics is enabled' do
    before do
      Rails.configuration.stubs(:analytics).returns(enabled: true, kafkas: ['localhost:9092'])
    end

    subject {Analytics::PublisherWorker.new}

    context '::perform_inline_or_async' do
      subject {Analytics::PublisherWorker}
      context 'without exceptions' do
        before do
          subject.any_instance.expects(:perform)
          subject.expects(:perform_async).never
        end

        it 'performs inline' do
          subject.perform_inline_or_async(channel: 'foo', message: {foo: 1})
        end
      end

      context 'with exceptions' do
        before do
          subject.any_instance.stubs(:perform).raises(Sidekiq::Retries::Retry, 'foo')
          subject.expects(:perform_async)
        end

        it 'performs async' do
          subject.perform_inline_or_async(channel: 'foo', message: {foo: 1})
        end
      end
    end

    context 'and connection pool times out' do
      before do
        publisher = stub
        publisher.stubs(:publish).raises(Timeout::Error, 'foo')
        subject.stubs(:publisher).returns(publisher)
      end
      it 'should retry' do
        expect {subject.perform(channel: 'foo', message: {foo: 1})}.to raise_error(Sidekiq::Retries::Retry)
      end
    end

    it 'should raise with incorrect parameters' do
      # should have :message and :channel
      expect {subject.perform({})}.to raise_error(ArgumentError)
      # :message should be a hash
      expect {subject.perform(channel: 'foo', message: :bar)}.to raise_error(ArgumentError)
    end

    it 'should add src and publish' do
      message   = {foo: 3}
      expected  = {foo: 3, 'src' => 'xact'}
      publisher = stub
      publisher.expects(:publish).with('donkey', expected)
      subject.expects(:publisher).returns(publisher)
      subject.perform(channel: 'donkey', message: message)
    end
  end
end
