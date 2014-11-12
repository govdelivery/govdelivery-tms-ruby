class Keyword < ActiveRecord::Base
  attr_accessible :name, :response_text, :is_default

  # for at least one of our vendors (twilio) we need to support stop, quit, cancel, and unsubscribe
  # http://www.twilio.com/help/faq/sms/does-twilio-support-stop-block-and-cancel-aka-sms-filtering
  STOP_WORDS  = %w(stop stopall unsubscribe cancel end quit) # we treat stopall and stop the same
  START_WORDS = %w(start yes)
  HELP_WORDS = %w(help info)
  DEFAULT_WORDS = %w(default)
  RESERVED_KEYWORDS = STOP_WORDS + START_WORDS + HELP_WORDS + DEFAULT_WORDS

  has_many :inbound_messages, inverse_of: :keyword
  has_many :commands, dependent: :delete_all

  belongs_to :account
  validates_presence_of :name
  validates_length_of :name, :maximum => 160
  validates_format_of :name, without: / /, message: 'No spaces allow in keyword name'
  validates_uniqueness_of :name, :scope => [:account_id]
  validates_length_of :response_text, :maximum => 160

  scope :custom, ->{ where.not(name: RESERVED_KEYWORDS) }

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
    command.save!
    command
  end

  def create_command(params)
    command            = self.commands.build params
    command.keyword    = self #strange that this is neccessary
    command.save
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
    RESERVED_KEYWORDS.include? self.name
  end

  def default?
    DEFAULT_WORDS.include? self.name
  end

  private

  def sanitize_name(n)
    self.class.sanitize_string(n)
  end
end
