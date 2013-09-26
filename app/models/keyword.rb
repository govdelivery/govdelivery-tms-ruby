class Keyword < ActiveRecord::Base
  attr_accessible :name, :response_text

  # for at least one of our vendors (twilio) we need to support stop, quit, cancel, and unsubscribe
  # http://www.twilio.com/help/faq/sms/does-twilio-support-stop-block-and-cancel-aka-sms-filtering
  STOP_WORDS = %w(stop quit unsubscribe cancel)
  RESERVED_KEYWORDS = STOP_WORDS + ['help']

  has_many :inbound_messages, inverse_of: :keyword
  belongs_to :vendor, :class_name=>'SmsVendor'
  belongs_to :account
  belongs_to :event_handler, :dependent => :destroy
  validates_presence_of :name, :account, :vendor
  validates_length_of :name, :maximum => 160
  validates_uniqueness_of :name, :scope => [:vendor_id, :account_id]
  validate :name_not_reserved
  validates_length_of :response_text, :maximum => 160

  class << self
    def stop?(text)
      # Message is a stop request if it starts with a stop word.
      !!(text =~ /^\s*(#{STOP_WORDS.join("|")})(\s|$)/i)
    end
  end

  def name=(n)
    write_attribute(:name, sanitize_name(n))
  end

  def add_command!(params)
    cmd = commands.new(params).tap{|c| c.account = self.account}
    cmd.save!
    cmd
  end

  def execute_commands(params=CommandParameters.new)
    params.account_id = self.account_id
    commands.each{|a| a.call(params)} if event_handler
  end

  def commands
    unless event_handler
      self.create_event_handler!
      self.save!
    end
    event_handler.commands
  end

  private

  def sanitize_name(n)
    n.try(:downcase).try(:strip)
  end

  def name_not_reserved
    if RESERVED_KEYWORDS.any? { |kw| /^(#{kw} |#{kw}$)/ =~ self.name }
      errors.add(:name, "Illegal keyword name #{self.name}")
    end
  end
end
