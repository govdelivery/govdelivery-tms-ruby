require 'rails_helper'

describe Sidekiq::DynamicQueue::Middleware do
  subject { Sidekiq::DynamicQueue::Middleware::Client.new }

  class RadWorker
    include Sidekiq::Worker
    sidekiq_options queue:             'wubble',
                    dynamic_queue_key: ->(args) {
                      args['value'].reverse
                    }
  end

  it 'should change the queue' do
    Sidekiq::RateLimitedQueue.expects(:includes_queue?).returns(true)
    queue = 'wubble'
    item  = {'args' => [{'value' => 'moms'}], 'queue' => 'wubble'}
    expect(subject.call(RadWorker, item, queue) { 'foo' }).to eq({"args" => [{"value" => "moms"}], "queue" => "wubble_smom"})
    expect(item['queue']).to eq 'wubble_smom'
    expect(queue).to eq 'wubble_smom'
  end

  it 'should not change the queue' do
    Sidekiq::RateLimitedQueue.expects(:includes_queue?).returns(false)
    queue = 'wubble'
    item  = {'args' => [{'value' => 'moms'}], 'queue' => 'wubble'}
    expect(subject.call(RadWorker, item, queue) { 'foo' }).to eq(item)
    expect(item['queue']).to eq 'wubble'
    expect(queue).to eq 'wubble'
  end

end