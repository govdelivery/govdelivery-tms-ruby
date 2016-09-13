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
    @capi     = CallbacksAPIClient.new
    @webhooks = []
  rescue => e
    log.error "Could not unregister reset @capi or @webhooks: #{e.message}"
  end
end

Before('@Dev-Safety') do |_scenario|
  begin
    log.info "\tSkipping on Dev with Non-Live Account".yellow if dev_not_live?
  rescue => e
    log.error "Could not print message about skipping dev to stdout."
  end
end

# Set our Twilio test account to have no callbacks when we are done
After('@Twilio') do |_scenario|
  begin
    twil = TwilioClientManager.default_client
    twil.account.incoming_phone_numbers.get(configatron.test_support.twilio.phone.sid).update(
      voice_url: '',
      sms_url:   ''
    )
  rescue => e
    log.error "Could not reset our twilio account callbacks message: #{e.message}"
  end
end

AfterConfiguration do |_config|
  configatron.lock!
end

After('@keyword') do
  ensure_deleted(@keyword)
end

After('@template') do
  ensure_deleted(@template)
end

After('@webhooks') do |scenario|
  # Return registered webhooks, and callback endpoints to their pre-test state
  @webhooks.each do |webhook|
    begin
      webhook.delete!
    rescue => e
      log.error "Could not unregister webhook: #{e.message}"
    end
  end

  unless scenario.failed?
    log.info 'Deleting Callback URIs'
    @capi.destroy_all_callback_uris
  end
end
