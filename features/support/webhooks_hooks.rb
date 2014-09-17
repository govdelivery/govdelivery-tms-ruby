Before do |scenario|
	puts "Starting scenario: "
    @capi = Callbacks_API_Client.new(callbacks_api_root)
    puts @capi.callbacks_root
end

After('@webhooks') do
  @capi.destroy_all_callback_uris
  # TODO: Wouldn't it be better to only delete hooks we created for this test, not all hooks on the account?
  hooks = tms_client.webhooks
  hooks.get
  hooks.collection.each do |hook|
    hook.delete
  end
end
