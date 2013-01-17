module RecipientStatus
  extend Enumerable

  NEW = 'new'
  SENDING = 'sending'
  SENT = 'sent'
  FAILED = 'failed'
  BLACKLISTED = 'blacklisted'
  CANCELED = 'canceled'

  def self.each(&block)
    [NEW, SENDING, SENT, FAILED, BLACKLISTED, CANCELED].each(&block)
  end

  def self.complete?(status)
    [SENT, FAILED].include?(status)
  end

  def self.not_sent?(status)
    [BLACKLISTED].include?(status)
  end
end
