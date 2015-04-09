class VoiceRecipient < ActiveRecord::Base
  include PhoneRecipient

  has_many :voice_recipient_attempts, -> { order('completed_at DESC') }

  def sent!(ack, completed_at, call_result)
    mark_sent!(:sent, ack, completed_at, call_result)
  end

  def failed!(ack = nil, completed_at = nil, error_message = nil)
    fail!(nil, ack, completed_at, error_message)
    raise Recipient::ShouldRetry if self.sending?
  end

  def retries_exhausted?
    # the current retry count is one more than the number of retries so far
    (retries + 1) >= message.max_retries
  end

  def retries
    voice_recipient_attempts.count
  end

  def secondary_status
    voice_recipient_attempts.first.try(:description)
  end

  protected

  def record_attempt(ack, date_sent, description)
    vrr               = voice_recipient_attempts.build
    vrr.voice_message = message
    vrr.description   = description
    vrr.ack           = ack
    vrr.completed_at  = date_sent || Time.now
    vrr.save
  end

  def finalize(ack, completed_at, status_or_error_message)
    if ack.present? && status_or_error_message.present?
      record_attempt(ack, completed_at, status_or_error_message)
      status_or_error_message = nil
    end
    super(ack, completed_at, status_or_error_message)
  end
end
