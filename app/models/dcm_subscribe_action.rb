DcmSubscribeAction = Struct.new(:client) do
  # phone_number: a non-formatted number
  # data_string: the params from the subscribe action in the database
  # subscribe_args: the tokens used after the configured keyword. For example, 
  #   if the user texted "subscribe foo bar", the subscribe_args should be ['foo', 'bar']
  def call(phone_number, data_string, subscribe_args=[], phone_number_constructor=PhoneNumber.public_method(:new))
    pn = phone_number_constructor.call(phone_number)
    client.wireless_subscribe(pn.dcm, *parse(data_string))
  end

  private

  # account_code:topic1,topic2,topic3
  def parse(str)
    account_code, topics = str.split(':')
    [account_code, topics.split(',')]
  end
end
