require 'securerandom'
require 'govdelivery-proctor'
require 'govdelivery-tms-internal'
require 'thor'
require 'benchmark'

class EmailMessagesPerformanceTest < Thor

  # Sends email messages to random recipients for TMS performance testing.
  ENVS = { 'qc'   => 'https://qc-tms.govdelivery.com',
           'int'  => 'https://int-tms.govdelivery.com',
           'stg'  => 'https://stage-tms.govdelivery.com',
           'prod' => 'https://tms.govdelivery.com' }

  option :environment, aliases: ['-e'], required: true, default: 'qc', type: :string, desc: 'qc,int,stg,prod'
  option :api_key, aliases: ['-k'], type: :string, required: true
  option :from_email, aliases: ['f'], type: :string, required: true
  option :recipients, aliases: ['-r'], type: :numeric, required: true, default: 1, desc: 'number of recipients per message'
  method_option :n, type: :numeric, desc: 'total number of requests', required: true
  method_option :c, type: :numeric, desc: 'max number of concurrent requests', default: 1
  desc 'send', 'send messages to randomly created recipients'

  def send

    total_requests = options[:n]
    thread_count = options[:c]

    work_queue = Queue.new
    total_requests.times do
      work_queue << ->(client){
        message = client.email_messages.build(
          body: 'performance test message',
          subject: 'Performance testing TMS email message sends',
          from_email: options[:from_email]
        )
        options[:recipients].times do |i|
          message.recipients.build(email: recipient(i))
        end
        message.post
      }
    end


    client = client_factory(options[:api_key], ENVS.fetch(options[:environment]))

    start_time = Time.now

    threads = thread_count.times.map{
      Thread.new do
        times = []
        until work_queue.empty?
          work = work_queue.pop(true) rescue nil
          next unless work

          start = Time.now
          work.call(client)
          times << Time.now - start
        end
        Thread.current[:times] = times
      end
    }

    threads.map(&:join)

    real_time = Time.now - start_time

    results = threads.map{|t| t[:times]}
    xs = results.flatten
    num = xs.size
    total_time = xs.reduce(:+)
    average = total_time/num.to_f
    puts "requests: #{num}"
    puts "real_time: #{real_time}s"
    puts "rps: #{num/real_time.to_f}"
    puts "average: #{average}s"
  end


  private

  def recipient i=0
    "#{SecureRandom.hex(6)}tms.activity.perf.test#{i}@sink.govdelivery.com"
  end

  def client
    @client ||= client_factory(options[:api_key], ENVS.fetch(options[:environment]))
  end

  def client_factory(key, root)
    GovDelivery::TMS::Client.new(key, api_root: root, logger: log)
  end

  def log
    GovDelivery::Proctor.log
  end

end

EmailMessagesPerformanceTest.start(ARGV)
