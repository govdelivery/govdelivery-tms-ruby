require 'base'

class CmsThrottledWorker
  include Workers::Base

  sidekiq_options retry: false

  def perform(*args)
    from_queue, to_queue = ['queue:cms_throttled', 'queue:default']

    messages_per_minute = YAML.load_file(
      Rails.root.join('config/throttle_email_sending.yml')
    )['messages_per_minute']

    process_batch(messages_per_minute, from_queue, to_queue)
  end

  def process_batch(n, from_queue, to_queue)
    Sidekiq.redis do |conn|
      n = [conn.llen(from_queue), n].min
      conn.pipelined do
        n.times do
          conn.rpoplpush(from_queue, to_queue)
        end
      end
    end
  end
end
