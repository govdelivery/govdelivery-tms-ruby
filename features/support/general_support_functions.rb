Before() do |scenario|
  @capi = Callbacks_API_Client.new(callbacks_api_root)
  @webhooks = []
end


Before('@Dev-Safety') do |scenario|
  STDOUT.puts "\tSkipping on Dev with Non-Live Account" if dev_not_live?
end

# Set our Twilio test account to have no callbacks when we are done
After('@Twilio') do |scenario|
  twil = Twilio::REST::Client.new twilio_test_account_creds[:sid], twilio_test_account_creds[:token]
  twil.account.incoming_phone_numbers.get(twilio_test_support_number[:sid]).update(
    :voice_url => '',
    :sms_url => ''
  )
end

# Destroy created endpoints on the Test Support App if we don't need to keep them
After('@Test-Support-App') do |scenario|
  if not scenario.failed?
    STDOUT.puts "Deleting Callback URIs"
    @capi.destroy_all_callback_uris
  end
end

def backoff_check(check, condition, desc)

  slept_time = 0
  min = 0
  max = environment == :development ? 5 : 9;

  # 2 ^ 9 = ~ 8.5 minutes
  # Max time waited: 17.05 minutes
  for x in min..max
    sleep_time = 2 ** x
    sleep(sleep_time)
    slept_time += sleep_time

    check.call()
    break if condition.call()
    raise "#{desc} has taken too long. Have waited #{slept_time} seconds" if x >= max
  end
  puts "Total time waited to #{desc}: #{slept_time}"
end

def random_string
  "#{Time.now.to_i}::#{rand(100000)}"
end