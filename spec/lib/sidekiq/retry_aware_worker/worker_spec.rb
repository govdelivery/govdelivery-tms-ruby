require 'rails_helper'

describe Sidekiq::RetryAwareWorker::Worker do
  class RetryingWorker
    include Sidekiq::Worker
  end

  subject { RetryingWorker.new }

  describe '#retrying?' do
    it 'should return the correct value' do
      expect(subject.retrying?).to be(false)
      subject.retry_count = 0
      expect(subject.retrying?).to be(true)
    end
  end
end
