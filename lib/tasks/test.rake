namespace :test do
  desc 'Runs client/server integration tests. Start sidekiq and set SIDEKIQ_PID first!'
  task integration: 'test:integration:setup' do
    puts 'Warning: SIDEKIQ_PID not set. Tests will fail unless it is running!' unless ENV['SIDEKIQ_PID']
    begin
      # start WEBrick in a thread
      port = (ENV['WEBRICK_PORT'] || '3000').to_i
      server = Thread.new { Rack::Server.start(app: Rails.application, Port: port, AccessLog: []) }
      puts 'running integration tests in five seconds...'
      sleep(5)

      require 'test/client_integration_test'
      ClientIntegrationTest.new.run

      server.terminate
    ensure
      Process.kill('TERM', ENV['SIDEKIQ_PID'].to_i) if ENV['SIDEKIQ_PID']
    end
    puts 'Tests complete!'
  end

  namespace :integration do
    desc 'Sets up integration test data (in dev DB by default)'
    task setup: :environment do
      sms_loopback = SmsVendor.find_or_create_by_name!(name: 'Loopback SMS Sender',
                                                       worker: 'LoopbackSmsWorker',
                                                       username: 'dont care',
                                                       password: 'dont care',
                                                       from: '1555111222',
                                                       vtype: :sms)

      voice_loopback = VoiceVendor.find_or_create_by_name!(name: 'Loopback Voice Sender',
                                                           worker: 'LoopbackVoiceWorker',
                                                           username: 'dont care',
                                                           password: 'dont care',
                                                           from: '1555111222')

      email_loopback = EmailVendor.find_or_create_by_name!(name: 'Email Loopback Sender',
                                                           from: 'GovDelivery LoopbackSender',
                                                           worker: 'LoopbackEmailWorker')

      from_address = FromAddress.find_or_create_by_from_email!(from_email: 'test@sink.govdelivery.com')

      account = Account.find_or_create_by_name!(voice_vendor: voice_loopback,
                                                sms_vendor: sms_loopback,
                                                email_vendor: email_loopback,
                                                name: 'Integration Test',
                                                from_address: from_address)

      account.users.find_or_create_by_email!(email: 'test@sink.govdelivery.com', password: 'abcd1234')
    end
  end
end
