require 'base'

class MarkOldRecipientsAsInconclusive
  include Workers::Base
  sidekiq_options unique: true, retry: false

  def perform(*args)
    [SmsRecipient, VoiceRecipient, EmailRecipient].each do |recipient_scope|
      mark_inconclusive!(ExpiredRecipientQuery.new(recipient_scope))
    end
  end

  def mark_inconclusive!
    expired.update_all(
      status: RecipientStatus::INCONCLUSIVE,
      updated_at: Time.now
    )
  end
end
