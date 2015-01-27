class Keyword < ActiveRecord::Base
  attr_accessible :name, :response_text, :is_default

  BASE_KEYWORDS     = ["stop", "start", "help", "default"]
  # for at least one of our vendors (twilio) we need to support stop, quit, cancel, and unsubscribe
  # http://www.twilio.com/help/faq/sms/does-twilio-support-stop-block-and-cancel-aka-sms-filtering
  STOP_WORDS        = %w(stop stopall unsubscribe cancel end quit) # we treat stopall and stop the same
  START_WORDS       = %w(start yes)
  HELP_WORDS        = %w(help info)
  DEFAULT_WORDS     = %w(default)
  RESERVED_KEYWORDS = STOP_WORDS + START_WORDS + HELP_WORDS + DEFAULT_WORDS

  has_many :inbound_messages, inverse_of: :keyword
  has_many :commands, dependent: :destroy

  belongs_to :account
  validates :account, presence: true
  validates :name,
            presence:   true,
            length:     {maximum: 160},
            format:     {without: / /, message: 'No spaces allow in keyword name'},
            uniqueness: {scope: [:account_id]},
            exclusion:  {in: RESERVED_KEYWORDS - BASE_KEYWORDS, message: "%{value} is a reserved keyword."}
  validates :response_text, length: {maximum: 160}

  scope :custom, -> { where.not(name: RESERVED_KEYWORDS) }
  scope :with_name, ->(name) { where(self.arel_table[:name].matches(name.downcase)) }


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
    command         = self.commands.build params
    command.keyword = self #strange that this is neccessary
    command.save!
    command
  end

  def create_command(params)
    command         = self.commands.build params
    command.keyword = self #strange that this is neccessary
    command.save
    command
  end

  def execute_commands(params=CommandParameters.new)
    params.account_id = self.account_id if self.account_id
    commands.collect { |a| a.call(params) }
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
