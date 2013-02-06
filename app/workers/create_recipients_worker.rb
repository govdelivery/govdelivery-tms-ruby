require 'base'

class CreateRecipientsWorker
  include Workers::Base

  def self.job_key(message_id)
    "xact:#{self.to_s.underscore}_in_progress_#{message_id}"
  end

  def perform(options)
    message = options['klass'].constantize.find(options['message_id'])
    recipient_params = options['recipients']
    if message && !recipient_params.blank?
      message.create_recipients(recipient_params)
      message.worker.send(:perform_async, {:message_id => message.id}.merge!(options['send_options']))
    elsif message
      message.check_complete!
    end
  ensure
    Rails.cache.delete(self.class.job_key(message.id)) if message
  end
end