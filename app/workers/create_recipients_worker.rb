require 'base'

class CreateRecipientsWorker
  include Workers::Base

  def self.perform_async_with_job_key(params)
    Rails.cache.write(job_key(params[:message_id]), 1)
    perform_async_without_job_key(params)
  end

  class << self
    alias_method_chain :perform_async, :job_key
  end

  def self.job_key(message_id)
    "xact:#{self.to_s.underscore}_in_progress_#{message_id}"
  end

  def perform(options)
    message = options['klass'].constantize.find(options['message_id'])
    recipient_params = options['recipients']
    if message && recipient_params.present?
      message.create_recipients(recipient_params)
      message.worker.perform_async({:message_id => message.id}.merge!(options['send_options']))
    elsif message
      message.complete!
    end
  ensure
    Rails.cache.delete(self.class.job_key(message.id)) if message
  end
end
