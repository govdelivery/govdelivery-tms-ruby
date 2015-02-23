require 'rails_helper'
describe Analytics::PublisherWorker do
  it 'should not perform when analytics is disabled' do
    Rails.configuration.analytics.expects(:[]).with(:enabled).returns(false)
    YaketyYak::Publisher.expects(:new).never
    Analytics::PublisherWorker.new.perform({})
  end

  describe 'when analytics is enabled' do
    before do
      Rails.configuration.analytics.stubs(:[]).with(:enabled).returns(true)
    end

    subject { Analytics::PublisherWorker.new }

    context "and connection pool times out" do
      before do
        YaketyYak::Publisher.any_instance.stubs(:publish).raises(Timeout::Error, 'foo')
      end
      it 'should retry' do
        expect { subject.perform({channel: "foo", message: {foo: 1}}) }.to raise_error(Sidekiq::Retries::Retry)
      end
    end

    it 'should raise with incorrect parameters' do
      # should have :message and :channel
      expect { subject.perform({}) }.to raise_error(ArgumentError)
      # :message should be a hash
      expect { subject.perform({channel: "foo", message: :bar}) }.to raise_error(ArgumentError)
    end

    it 'should add src and publish' do
      message  = {foo: 3}
      expected = {foo: 3, src: 'xact'}
      YaketyYak::Publisher.any_instance.expects(:publish).with('donkey', expected)
      subject.perform(channel: 'donkey', message: message)
    end
  end
end