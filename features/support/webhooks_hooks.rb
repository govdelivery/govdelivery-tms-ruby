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

def backoff_check(check, condition, desc)

  slept_time = 0

  # 2 ^ 8 = ~ 4.2 minutes
  for x in 0..8
    sleep_time = 2 ** x
    puts "Waiting #{sleep_time} seconds to #{desc}"
    sleep(sleep_time)
    slept_time += sleep_time

    check.call()
    break if condition.call()
    raise "#{desc} has taken too long. Have waited #{slept_time} seconds" if x == 8
  end
  puts "Total time waited to #{desc}: #{slept_time}"
end