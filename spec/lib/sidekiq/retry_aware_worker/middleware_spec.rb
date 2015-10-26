require 'rails_helper'

describe Sidekiq::RetryAwareWorker::Middleware do
  class Donkey
    attr_accessor :retry_count
  end

  subject { Sidekiq::RetryAwareWorker::Middleware.new }
  let(:worker) { Donkey.new }

  describe '#call' do
    it 'should set thing on worker' do
      subject.call(worker, {}, :default) do |_, _, _|
        :awesome
      end
      expect(worker.retry_count).to be(nil)
      subject.call(worker, {"retry_count" => 10}, :default) do |_, _, _|
        :awesome
      end
      expect(worker.retry_count).to eq(10)
    end
  end
end
