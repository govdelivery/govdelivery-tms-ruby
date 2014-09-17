Before() do |scenario|
    @capi = Callbacks_API_Client.new(callbacks_api_root)
    puts @capi.callbacks_root
    @webhooks = []
end

After('@webhooks') do
  # Return registered webhooks, and callback endpoints to their pre-test state
  @webhooks.each do |webhook|
    begin
      webhook.delete
    rescue => e
      STDERR.puts "Could not unregister webhook: #{e.message}"
    end
  end

  @capi.destroy_all_callback_uris
end