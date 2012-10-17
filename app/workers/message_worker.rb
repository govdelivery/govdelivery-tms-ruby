class MessageWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  
  def perform(message_id)
    message = Message.find(message_id)

    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

    @account = @client.account
    twilio_response = @account.sms.messages.create({:from => '(651) 433-6311', :to => message.recipients, :body => message.short_body})
    
    message.update_attributes(:ack => twilio_response.sid, :completed => Time.now)
  end
end