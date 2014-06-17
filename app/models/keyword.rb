class Keyword < ActiveRecord::Base
  attr_accessible :name, :response_text

  # for at least one of our vendors (twilio) we need to support stop, quit, cancel, and unsubscribe
  # http://www.twilio.com/help/faq/sms/does-twilio-support-stop-block-and-cancel-aka-sms-filtering
  STOP_WORDS  = %w(stop stopall unsubscribe cancel end quit) # we treat stopall and stop the same
  START_WORDS = %w(start yes)
  HELP_WORDS = %w(help info)
  RESERVED_KEYWORDS = STOP_WORDS + START_WORDS + HELP_WORDS

  has_many :inbound_messages, inverse_of: :keyword
  has_many :commands

  #TEMPORARY for data migration:
  belongs_to :event_handler, :dependent => :destroy

  scope :custom, where('type is null')
  scope :special, where("type is not null")

  belongs_to :vendor, class_name: 'SmsVendor'
  belongs_to :account
  validates_presence_of :name
  validates_presence_of :vendor
  validates_length_of :name, :maximum => 160
  validates_format_of :name, without: / /, message: 'No spaces allow in keyword name'
  validates_uniqueness_of :name, :scope => [:vendor_id, :account_id]
  validate :name_not_reserved
  validates_length_of :response_text, :maximum => 160

  before_validation :set_vendor
  before_validation :set_special_name

  def self.get_keyword keyword_name, vendor, account_id
    account = Account.find(account_id) if account_id
    # account_scope
    if account.present?
      case
      when STOP_WORDS.include?(keyword_name)
        account.stop_keyword
      when HELP_WORDS.include?(keyword_name)
        account.help_keyword
      when (keyword = account.keywords.where(name: keyword_name).first).present?
        keyword
      else
        account.default_keyword
      end
    #vendor scope
    else # vendor is always present like the wind
      case
      when STOP_WORDS.include?(keyword_name)
        vendor.stop_keyword
      when START_WORDS.include?(keyword_name)
        vendor.start_keyword
      when HELP_WORDS.include?(keyword_name)
        vendor.help_keyword
      when (keyword = vendor.keywords.where(name: keyword_name, account_id: nil).first).present?
        keyword
      else
        vendor.default_keyword
      end
    end
  end


  def self.stop?(text)
    # Message is a stop request if it starts with a stop word.
    !!(text =~ /^\s*(#{STOP_WORDS.join("|")})(\s|$)/i)
    # STOP_WORDS.include? sanitize_name(text.strip.split(' ').first) # another way perhaps
  end

  def self.help?(text)
    sanitize_string(text.split.first) == 'help'
  end

  def name=(n)
    write_attribute(:name, sanitize_name(n))
  end

  def create_command!(params)
    command = self.commands.build params
    command.keyword = self #strange that this is neccessary
    command.account_id = self.account_id if self.account_id
    command.save!
    command
  end

  def execute_commands(params=CommandParameters.new)
    params.account_id = self.account_id if self.account_id
    commands.collect{|a| a.call(params) }
  end

  def self.sanitize_string(n)
    n.mb_chars.downcase.strip.to_s if n #just to allow invalidation
  end

  def special?
    false
  end

  def default?
    false
  end

  private

  # just a shortcut
  def set_vendor
    self.vendor ||= account.sms_vendor if account.present?
  end

  def set_special_name
    self.name ||= self.class.name if special?
  end

  def sanitize_name(n)
    self.class.sanitize_string(n)
  end

  def name_not_reserved
    if RESERVED_KEYWORDS.any? { |kw| /^(#{kw} |#{kw}$)/ =~ self.name }
      errors.add(:name, "Illegal keyword name #{self.name}")
    end
  end
end
