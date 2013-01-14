module RecipientStatus
  STATUS_NEW = 1
  STATUS_SENDING = 2
  STATUS_SENT = 3
  STATUS_FAILED = 4
  STATUS_BLACKLISTED = 5
  STATUS_CANCELED = 6

  def self.complete?(status)
    [STATUS_SENT, STATUS_FAILED].include?(status)
  end

  def self.not_sent?(status)
    [STATUS_BLACKLISTED].include?(status)
  end
end