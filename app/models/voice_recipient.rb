class VoiceRecipient < ActiveRecord::Base
  include PhoneRecipient

  has_many :voice_recipient_retries

  def sent!(ack, status_type=nil, date_sent=nil)
    mark_sent!(:sent, ack, date_sent, nil, status_type)
  end

  def busy!(ack, date_sent=nil)
    begin
      attempt!(:sent, ack, date_sent, nil, :busy)
    rescue AASM::InvalidTransition
      retry!(:sent, :busy)
      raise Recipient::ShouldRetry
    end
  end

  def no_answer!(ack, date_sent=nil)
    begin
      attempt!(:sent, ack, date_sent, nil, :no_answer)
    rescue AASM::InvalidTransition
      retry!(:sent, :no_answer)
      raise Recipient::ShouldRetry
    end
  end

  def failed!(ack=nil, completed_at=nil, error_message=nil)
    begin
      attempt!(:failed, ack, completed_at, error_message)
    rescue AASM::InvalidTransition
      retry!(:failed)
      raise Recipient::ShouldRetry
    end
  end

  def should_retry?
    self.sending? && retries < message.max_retries
  end

  # Record a retry for this recipient / voice message combination
  def retry!(s, ss=nil)
    voice_recipient_retries.build.tap do |vrr|
      vrr.voice_message = message
      vrr.completed_at = Time.now
      vrr.status = s
      vrr.secondary_status = ss
      vrr.save!
    end
  end

  def retries
    voice_recipient_retries.count
  end

  protected

  def finalize(*args)
    self.ack           ||= args[0]
    self.completed_at  = args[1] || Time.now
    self.error_message = args[2]
    self.secondary_status = args[3]
  end
end
