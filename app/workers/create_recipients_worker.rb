require 'base'

class CreateRecipientsWorker
  include Workers::Base

  def perform(options)
    message = Message.find(options['message_id'])
    recipient_params = options['recipients']
    if message && !recipient_params.blank?
      message.create_recipients(recipient_params)
      message.worker.send(:perform_async, {:message_id => message.id}.merge!(options['send_options']))
    elsif message
      message.complete!
    end
  end
end