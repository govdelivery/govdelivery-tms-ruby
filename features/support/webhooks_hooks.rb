After('@webhooks') do |scenario|
  # Return registered webhooks, and callback endpoints to their pre-test state
  @webhooks.each do |webhook|
    begin
      webhook.delete
    rescue => e
      STDERR.puts "Could not unregister webhook: #{e.message}"
    end
  end

  if not scenario.failed?
    STDOUT.puts "Deleting Callback URIs"
    @capi.destroy_all_callback_uris
  end
end