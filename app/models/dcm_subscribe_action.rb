# Sends a subscription action to DCM
#
# Example: call("1+2222222222", "ACME:TOPIC_1,TOPIC2", ['foo@bar.com']
#   -> Subscribe foo@bar.com to ACME topics TOPIC_1 and TOPIC_2
#   In this scenario, the user text was something like "subscribe foo@bar.com"
#
# Example: call("1+2222222222", "ACME:TOPIC_1,TOPIC2", [])
#   -> Subscribe 1+2222222222 to ACME topics TOPIC_1 and TOPIC_2 
#   In this scenario, the user text was something like "subscribe"
#
DcmSubscribeAction = Struct.new(:client) do
  # phone_number: the incoming phone number string
  # data_string: the params from the subscribe action in the database
  # subscribe_args: an array of the tokens the user typed after the configured keyword. For example, 
  #   if the user texted "subscribe foo@bar.com", the subscribe_args should be ["foo@bar.com"].
  def call(phone_number, data_string, subscribe_args=[], phone_number_constructor=PhoneNumber.public_method(:new))
    if(email_address = extract_email(subscribe_args))
      client.email_subscribe(email_address, *parse(data_string))
    else
      pn = phone_number_constructor.call(phone_number)
      client.wireless_subscribe(pn.dcm, *parse(data_string))
    end
  end

  private

  def extract_email(subscribe_args)
    if !subscribe_args[0].nil? && subscribe_args[0] =~ /@/
      subscribe_args[0]
    end
  end

  # account_code:topic1,topic2,topic3
  def parse(str)
    account_code, topics = str.split(':')
    [account_code, topics.split(',')]
  end
end
