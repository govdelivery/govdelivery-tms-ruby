require 'base'

class MarkOldRecipientsAsInconclusive
  include Workers::Base
  sidekiq_options unique: true, retry: false

  def perform(*args)
    [SmsRecipient, VoiceRecipient, EmailRecipient].each do |recipient_scope|
      mark_inconclusive!(ExpiredRecipientQuery.new(recipient_scope))
    end
  end

  def mark_inconclusive!(expired)
    expired.find_each do |recipient|
      begin
        recipient.mark_inconclusive!
      rescue AASM::InvalidTransition => e
        logger.warn(e)
      end
    end
  end
end
