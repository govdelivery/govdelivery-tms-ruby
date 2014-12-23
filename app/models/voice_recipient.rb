class VoiceRecipient < ActiveRecord::Base
  include PhoneRecipient

  has_many :voice_recipient_attempts, -> { order('completed_at DESC') }

  def sent!(ack, date_sent, call_result)
    date_sent||= Time.now
    mark_sent!(:sent, ack, date_sent, nil, call_result)
  end

  def attempt!(ack, date_sent, call_result)
    begin
      mark_attempt!(nil, ack, date_sent, nil, call_result)
    rescue AASM::InvalidTransition
      record_attempt(ack, date_sent, call_result)
      raise Recipient::ShouldRetry
    end
  end

  def retries_exhausted?
    # the current retry count is one more than the number of retries so far
    (retries+1) >= message.max_retries
  end

  def retries
    voice_recipient_attempts.count
  end

  def secondary_status
    voice_recipient_attempts.first.try(:description)
  end

  protected
  def record_attempt(ack, date_sent, description)
    voice_recipient_attempts.build.tap do |vrr|
      vrr.voice_message = message
      vrr.description   = description
      vrr.ack           = ack
      vrr.completed_at  = date_sent || Time.now
      vrr.save!
    end
  end

  def finalize(ack, completed_at, error_message, call_status)
    self.ack = ack if ack.present?
    record_attempt(ack, completed_at, call_status) if ack.present? && call_status.present?
    self.completed_at  = completed_at || Time.now
    self.error_message = error_message
  end
end
