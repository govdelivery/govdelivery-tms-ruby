require 'base'

class MarkOldRecipientsAsInconclusive
  include Workers::Base
  sidekiq_options queue: :low,
                  unique: :until_executed,
                  run_lock_expiration: (60 * 60) * 24, # 1 day, let's be conservative
                  retry: false

  def perform(*_args)
    [SmsRecipient, VoiceRecipient, EmailRecipient].each do |relation|
      relation.timeout_expired.find_each do |recipient|
        begin
          recipient.mark_inconclusive!
        rescue AASM::InvalidTransition => e
          logger.warn(e)
        end
      end
    end
  end
end
