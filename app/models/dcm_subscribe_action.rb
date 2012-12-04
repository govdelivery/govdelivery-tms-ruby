DcmSubscribeAction = Struct.new(:client) do
  def call(phone_number, data_string, phone_number_constructor=PhoneNumber.public_method(:new))
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
