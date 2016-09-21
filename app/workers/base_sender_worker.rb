class BaseSenderWorker
  include Workers::Base
  attr_reader :options


  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
    complete_recipient_with_error!(msg['args'].first.symbolize_keys, msg['error_message'])
  end

  class << self
    def complete_recipient_with_error!(options, error_message)
      recipient = SmsRecipient.where(message_id: options[:message_id], id: options[:recipient_id]).first || raise(ActiveRecord::RecordNotFound)
      recipient.failed!(nil, nil, error_message)
    end

    def sending!(recipient, ack)
      recipient.sending!(ack)
    end
  end

  def perform(options={})
    @options = options.symbolize_keys!
    if (ack = send_batch!)
      mark_sending!(ack)
    end
  end

  def recipient
    @recipient ||= get_recipient_vendor_message[0]
  end

  def vendor
    @vendor ||= get_recipient_vendor_message[1]
  end

  def message
    @message ||= get_recipient_vendor_message[2]
  end

  def mark_sending!(batch_id)
    begin
      self.class.sending!(recipient, batch_id)
    rescue ActiveRecord::ConnectionTimeoutError => e
      self.class.delay(retry: 10).sending!(recipient, batch_id)
      raise Sidekiq::Retries::Fail.new(e)
    end

  end

  def get_recipient_vendor_message
    @recipient_vendor_message ||= begin
      temp_message   = nil
      temp_recipient = nil
      temp_vendor    = nil
      ActiveRecord::Base.connection_pool.with_connection do
        temp_message   = SmsMessage.includes(:sms_vendor).find(@options[:message_id])
        temp_recipient = temp_message.recipients.find(@options[:recipient_id])
        temp_vendor    = temp_message.vendor
      end
      [temp_recipient, temp_vendor, temp_message]
    end
  end
end
