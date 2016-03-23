# Destroy created endpoints on the Test Support App if we don't need to keep them
After('@Test-Support-App') do |scenario|
  unless scenario.failed?
    log.info 'Deleting Callback URIs'
    begin
      @capi.destroy_all_callback_uris
    rescue => e
      log.error "Failed to destroy callback uris error: #{e.message} capi:#{@capi}"
    end
  end
end

Before() do |_scenario|
  begin
    @capi = CallbacksAPIClient.new
    @webhooks = []
  rescue => e
    log.error "Could not unregister reset @capi or @webhooks: #{e.message}"
  end
end

Before('@Dev-Safety') do |_scenario|
  log.info "\tSkipping on Dev with Non-Live Account".yellow if dev_not_live?
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
    log.error "Could not reset our twilio account callbacks message: #{e.message}"
  end
end