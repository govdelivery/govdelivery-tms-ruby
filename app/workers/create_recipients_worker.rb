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
      enqueue_send_job(message, options['send_options'])
    elsif message
      message.complete!
    end
  ensure
    Rails.cache.delete(self.class.job_key(message.id)) if message
  end

  private

  def enqueue_send_job(message, send_options)
    if throttle?(message)
      logger.debug { "Throttling message id #{message.id}" }
      Odm::ThrottledTmsExtendedSenderWorker.perform_async(
        # Should we merge the other way around? Keeping it the way I found it
        # until I can confirm.
        {message_id: message.id}.merge(send_options)
      )
    else
      message.worker.perform_async({:message_id => message.id}.merge!(send_options))
    end
  end

  def throttle?(message)
    message_attributes = message.attributes
    get_attrs.any? {|h|
      message_attributes.slice(*h.keys) == h
    }
  end

  def get_attrs
    f = Rails.root.join('config/throttle_email_sending.yml')
    return [] unless f.exist?
    YAML.load_file(f).fetch('message_matchers', [])
  rescue
    # If something bad happens here, returning an empty array will allow us to
    # just move on and not throttle anything.
    Rails.logger.error("There was an error when trying to get throttling attributes.\n#{$!.message}\n#{$!.backtrace.join("\n")}")
    []
  end
end
