require 'colored'

# Destroy created endpoints on the Test Support App if we don't need to keep them
After('@Test-Support-App') do |scenario|
  unless scenario.failed?
    STDOUT.puts 'Deleting Callback URIs'
    begin
      @capi.destroy_all_callback_uris
    rescue => e
      STDERR.puts "Failed to destroy callback uris error: #{e.message} capi:#{@capi}"
    end
  end
end

Before() do |_scenario|
  begin
    @capi = CallbacksAPIClient.new
    @webhooks = []
  rescue => e
    STDERR.puts "Could not unregister reset @capi or @webhooks: #{e.message}"
  end
end

Before('@Dev-Safety') do |_scenario|
  begin
    STDOUT.puts "\tSkipping on Dev with Non-Live Account".red if dev_not_live?
  rescue => e
    STDERR.puts "Could not print message about skipping dev to stdout."
  end
end

# Set our Twilio test account to have no callbacks when we are done
After('@Twilio') do |_scenario|
  begin
    twil = TwilioClientManager.default_client
    twil.account.incoming_phone_numbers.get(configatron.test_support.twilio.phone.sid).update(
      voice_url: '',
      sms_url: ''
    )
  rescue => e
    STDERR.puts "Could not reset our twilio account callbacks message: #{e.message}"
  end
end