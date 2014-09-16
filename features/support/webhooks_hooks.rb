Before('@webhooks') do
    @capi = Callbacks_API_Client.new(callbacks_api_root)
    puts @capi.callbacks_root
end

After('@webhooks') do
    @capi.destroy_all_callback_uris
end