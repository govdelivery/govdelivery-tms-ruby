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
    queue = 'wubble'
    item  = {'args' => {'value' => 'moms'}, 'queue' => 'wubble'}
    subject.call(RadWorker, item, queue)
    expect(item['queue']).to eq 'wubble_smom'
    expect(queue).to eq 'wubble_smom'
  end

end