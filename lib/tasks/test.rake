namespace :test do
  namespace :integration do
    task :setup => :environment do
      sms_loopback = SmsVendor.find_or_create_by_name!(:name => 'Loopback SMS Sender',
                                                       :worker => 'LoopbackSmsWorker',
                                                       :username => 'dont care',
                                                       :password => 'dont care',
                                                       :from => '1555111222',
                                                       :vtype => :sms)

      voice_loopback = VoiceVendor.find_or_create_by_name!(:name => 'Loopback Voice Sender',
                                                           :worker => 'LoopbackVoiceWorker',
                                                           :username => 'dont care',
                                                           :password => 'dont care',
                                                           :from => '1555111222')

      email_loopback = EmailVendor.find_or_create_by_name!(:name => 'Email Loopback Sender',
                                                           :username => 'blah',
                                                           :password => 'wat',
                                                           :from => 'GovDelivery LoopbackSender',
                                                           :worker => 'LoopbackEmailWorker')

      account = Account.find_or_create_by_name!(:voice_vendor => voice_loopback,
                                                :sms_vendor => sms_loopback,
                                                :email_vendor => email_loopback,
                                                :name => 'Integration Test')

      account.users.find_or_create_by_email!(:email => "test@sink.govdelivery.com", :password => "abcd1234", :admin => true)

    end

    task :run => :setup do
      begin
        #start WEBrick in a thread
        port = (ENV['WEBRICK_PORT'] || '3000').to_i
        server = Thread.new { Rack::Server.start(:app => Rails.application, :Port => port, :AccessLog => []) }
        puts "running integration tests in five seconds..."
        sleep(5)

        require 'test/client_integration_test'
        ClientIntegrationTest.new.run

        server.terminate
      ensure
        Process.kill('TERM', ENV['SIDEKIQ_PID'].to_i) if ENV['SIDEKIQ_PID']
      end
      puts "Tests complete!"
    end
  end

end