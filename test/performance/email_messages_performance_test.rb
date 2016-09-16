require 'securerandom'
require 'govdelivery-proctor'
require 'govdelivery-tms-internal'
require 'configatron'

# Sends N_MESSAGES to N_RECIPIENTS for TMS email messages performance testing.
#
# XACT_ENV=qc bundle exec ruby test/performance/email_messages_performance_test.rb

N_RECIPIENTS = 1
N_MESSAGES = 1

def environment
  environments = [
    :qc,
    :integration,
    :stage,
    :prod
  ]
  env = ENV.fetch 'XACT_ENV'
  env.to_sym
end

# loading config data
require_relative '../../features/support/config/tms.rb'

def recipients
  @recipients ||= (0...N_RECIPIENTS).map{ |i| "#{SecureRandom.hex(6)}.tms.perf.test#{i}@sink.govdelivery.com" }
end

def recipient
  recipients.sample
end

def non_admin_client
  @non_admin_client ||= client_factory(configatron.tms.admin.token, configatron.tms.api_root)
end

def client_factory(token, root)
  GovDelivery::TMS::Client.new(token, api_root: root, logger: log)
end

def log
  GovDelivery::Proctor.log
end

def send_a_message
  message = non_admin_client.email_messages.build(
    body: 'performance test message',
    subject: 'Performance testing TMS email message sends',
    from_email: configatron.tms.from_email
  )
  message.recipients.build(email: recipient)
  message.post
end

N_MESSAGES.times.to_a.map do |i|
  Thread.new do
    send_a_message
    puts "Published message #{i+1} of #{N_MESSAGES}"
  end
end.map(&:join)
