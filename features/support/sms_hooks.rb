require 'colored'

# Before('@2waystatic') do |scenario|
#  # Register Twilio Requests Controller of the Environment we're interested in with the Xact Twilio Test number
#
#  @twilio_sms_receiver_uri = "#{xact_url}/twilio_requests"
#  twil = Twilio::REST::Client.new twilio_test_account_creds[:sid], twilio_test_account_creds[:token]
#  twil.account.incoming_phone_numbers.get(twilio_xact_test_number[:sid]).update(
#    :sms_url => @twilio_sms_receiver_uri
#  )
# end

After('@keyword') do |scenario|
  if !scenario.failed? && defined?(@keyword)
    STDOUT.puts 'Deleting keyword created for this test'.blue
    begin
      @keyword.delete
    rescue => e
      STDERR.puts "Could not delete keyword after run: #{e.message}"
    end
  end
end
