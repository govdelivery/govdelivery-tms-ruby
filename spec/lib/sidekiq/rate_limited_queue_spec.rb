require 'rails_helper'

describe Sidekiq::RateLimitedQueue do
  before do
    Sidekiq.options[:queues] = ['sender', 'default', 'webhook', 'stats', 'low']
    Sidekiq::RateLimitedQueue::Configuration.load!(Rails.root.join('test', 'fixtures', 'sidekiq_throttled_queues.yml'))
  end

  it 'should merge queue lists' do
    expect(Sidekiq.options[:queues]).to match_array ['sender', 'sender_sadklfjhasdlkfjhasldkj', 'default', 'webhook', 'stats', 'low']
  end

  it 'should list throttled queues' do
    expect(Sidekiq::RateLimitedQueue.throttled_queues).to match_array ['default', 'sender_sadklfjhasdlkfjhasldkj']
  end

  context 'limiting sender to 5 jobs every seconds' do
    subject { Sidekiq::RateLimitedQueue.new('default', Sidekiq.redis_pool) }
    it 'should pause the queue after five jobs in two seconds' do
      expect(subject.rate_limiting_enabled?).to be true

      expect(subject.check_rate_limit!).to be false
      5.times do
        expect(subject.enforce_rate_limit!).to be false
      end
      expect(subject.check_rate_limit!).to be false
      expect(subject.enforce_rate_limit!).to be true
      expect(subject.paused?).to be true
      sleep(2)
      expect(subject.check_rate_limit!).to be true
      expect(subject.paused?).to be false
    end

  end

  context 'some other queue' do
    subject { Sidekiq::RateLimitedQueue.new('ladies', Sidekiq.redis_pool) }
    it 'should be cool, honey bunny' do
      expect(subject.rate_limiting_enabled?).to be false
    end
  end

end