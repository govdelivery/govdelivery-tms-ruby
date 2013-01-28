require 'tms_client'

class ClientIntegrationTest

  def initialize
    @client = TMS::Client.new('test@sink.govdelivery.com', 'abcd1234', :api_root => 'http://localhost:3000')
  end

  def run
    test_phone_message_and_recipient_gets(@client.voice_messages, {:play_url => 'http://www.thesubstars.com'})
    test_phone_message_and_recipient_gets(@client.sms_messages, {:body => 'hey awesome'})
    test_email_message
  end

  protected

  def test_email_message
    puts @client.subresources
    message = @client.email_messages.build({:body => 'hey awesome', :subject => 'hi', :from_name => "bangin'"})
    email = "recipient00"
    70.times do
      message.recipients.build(:email => email)
      email = email.succ
    end
    post_message_and_verify_recipient_gets(message)
  end

  def test_phone_message_and_recipient_gets(message_collection, message_attributes)
    message = message_collection.build(message_attributes)
    phone = '+16125015456'
    60.times do
      message.recipients.build(:phone => phone)
      phone = phone.succ
    end
    post_message_and_verify_recipient_gets(message)
  end

  def post_message_and_verify_recipient_gets(message)
    puts "POST to #{message.href}"
    message.post
    puts "GET to #{message.href}:"
    message.get
    begin
      puts "GET to #{message.recipients.href}:"
      message.recipients.get
    rescue TMS::Request::InProgress => e
      puts "\t#{e.message}"
      puts "\tWaiting three seconds..."
      sleep(3)
      retry
    end

    next_recipients = next_page_of_recipients(message)
    prev_recipients = previous_page_of_recipients(next_recipients)

    individual_recipient(prev_recipients)
  end

  def next_page_of_recipients(message)
    puts "GET to #{message.recipients.next.href}"
    message.recipients.next.get
  end

  def previous_page_of_recipients(recipients)
    puts "GET to #{recipients.prev.href}"
    recipients.prev.get
  end

  def individual_recipient(recipients)
    recip = recipients.collection.first
    puts "GET to #{recip.href}"
    recip.get
    recip
  end

end


