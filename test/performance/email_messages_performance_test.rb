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
method_option :n, type: :numeric, desc: 'number of requests', default: 10
method_option :c, type: :numeric, desc: 'max number of concurrent requests', default: 1
desc 'send', 'send messages to randomly created recipients'
  def send

      n = options[:n]
      c = options[:c]
      g_size = (n.to_f/c).ceil
      g = (n.to_f/g_size).ceil
      t = 0

      summary = []
      averages = []
      results = []

      total_time = Benchmark.realtime do
        g.times do |i|
          threads = []
          m = 0
          row = ["Group #{i+1}"]

          cell = ''
          while (m < g_size) && (t < n) do
            threads << Thread.new do
              Thread.current[:time] = Benchmark.realtime do
                message = client.email_messages.build(
                  body: 'performance test message',
                  subject: 'Performance testing TMS email message sends',
                  from_email: options[:from_email] )
                message.recipients.build(email: recipient)
                message.post
            end
            cell << '.'
          end
          m += 1
          t += 1
        end
        threads.map(&:join)
        average = (threads.map{ |thread| thread[:time] }.reduce(:+) / threads.size) * 1000

         row << cell
         row << "Requests: #{threads.size}"
         row << "Average: #{average.round(0)} ms"

         averages << average
         results << row.join(' ')
      end
    end
     avg = averages.reduce(:+) / averages.size
     rps = n / total_time

     summary << "Total Requests: #{n}"
     summary << "Total Time: #{total_time.round(2)} seconds (#{(total_time * 1000).round(0)} ms)"
     summary << "Average Per Request: #{avg.round(0)} ms"
     summary << "Requests Per Second: #{rps.round(2)}\n"

     puts results
     puts
     puts summary
     puts
  end


private

  def recipient
    @recipient ||= "#{SecureRandom.hex(6)}.tms.perf.test@sink.govdelivery.com"
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
