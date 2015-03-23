require 'set'

class Account < ActiveRecord::Base
  attr_accessible :name, :sms_vendor, :email_vendor, :voice_vendor, :ipaws_vendor,
                  :sms_vendor_id, :email_vendor_id, :voice_vendor_id, :ipaws_vendor_id,
                  :from_address, :dcm_account_codes, :link_tracking_parameters

  belongs_to :email_vendor
  belongs_to :sms_vendor

  belongs_to :voice_vendor
  belongs_to :ipaws_vendor, class_name: 'IPAWS::Vendor'

  has_many :commands, through: :keywords
  has_many :keywords, dependent: :destroy
  has_many :email_messages, dependent: :delete_all
  has_many :email_recipients, through: :email_messages, source: :recipients
  has_many :email_recipient_clicks, through: :email_messages
  has_many :email_recipient_opens, through: :email_messages
  has_many :inbound_messages, dependent: :nullify
  has_many :sms_messages, dependent: :delete_all
  has_many :sms_recipients, through: :sms_messages, source: :recipients
  has_many :sms_prefixes, inverse_of: :account, dependent: :destroy
  has_many :stop_requests, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :voice_messages, dependent: :delete_all
  has_many :voice_recipients, through: :voice_messages, source: :recipients
  has_many :incoming_voice_messages, through: :from_numbers
  has_many :call_scripts, through: :voice_messages
  has_many :webhooks, dependent: :delete_all

  has_many :from_addresses, inverse_of: :account, dependent: :destroy
  has_one :default_from_address, -> { where(is_default: true) }, class_name: FromAddress

  has_many :from_numbers, inverse_of: :account, dependent: :destroy
  has_one :default_from_number, -> { where(is_default: true) }, class_name: FromNumber

  after_create :create_base_keywords!

  serialize :dcm_account_codes, Set
  delegate :from_email, :reply_to_email, :bounce_email, :reply_to, :errors_to, to: :default_from_address
  delegate :from_number, to: :default_from_number

  before_validation :normalize_dcm_account_codes
  before_validation :generate_sid, on: :create

  validates :name, presence: true, length: {maximum: 255}, uniqueness: true
  validates :sid, presence: true
  validate :has_one_default_from_address, if: '!email_vendor_id.blank?'
  validate :has_one_default_from_number, if: '!voice_vendor_id.blank?'
  validate :validate_sms_prefixes, :validate_sms_vendor
  # ONE: HYRULE, TWO: STRONGMAIL
  validates :link_encoder, inclusion: { in: %w(TWO ONE), allow_nil: true,
                                message: "%{value} is not a valid link_encoder" }

  scope :with_sms, where('sms_vendor_id is not null')

  def create_command!(keyword_name, params)
    keyword = keywords.where(name: keyword_name).first_or_create!
    keyword.create_command!(params)
  end

  def feature_enabled?(feature)
    !!self.send("#{feature}_vendor")
  end

  ['start', 'stop', 'help'].each do |name|
    define_method(name) do |command_parameters|
      keyword = self.send(:"#{name}_keyword")
      keyword.commands.each do |command|
        command.call(command_parameters)
      end if keyword
    end

    define_method("#{name}_keyword") do
      keywords.where(name: name).first
    end
  end
  alias_method :help!, :help

  def default_keyword
    keywords.where(name: 'default').first
  end

  ##
  # The bang version does the same as the regular stop method, with the addition
  # of the creation of an (account-specific) stop request.  Note that when stop! is
  # called on the vendor, it turns around and calls stop (no bang) on each account.
  # This is because a null account_id in stop_requests covers the entire
  # vendor.  In a shared vendor, though, we might get an account-specific stop request
  # (such as 'MNTRAFFIC STOP').  In this case we only want to stop texts from that
  # particular account.
  #
  def stop!(command_parameters)
    # We need to maintain a blacklist at the account level.
    # This will prevent sending from a shared vendor.
    unless stop_requests.exists?(phone: command_parameters.from, vendor_id: sms_vendor)
      stop_requests.create!(phone: command_parameters.from, vendor: sms_vendor)
    end
    stop(command_parameters)
  end

  def start!(command_parameters)
    stop_requests.where(phone: command_parameters.from).delete_all #its ok if it doesn't exist
    start(command_parameters)
  end

  def from_email_allowed?(email)
    !email.nil? && from_addresses.where("lower(from_email) = ?", email.downcase).count == 1
  end

  def from_number_allowed?(phone)
    !phone.nil? && from_numbers.where("phone_number = ?", phone).count == 1
  end

  # some sugar for working with keywords on the console
  def keywords arg=nil
    if arg
      super.where(name: arg).first
    else
      super
    end
  end

  ##
  # Make link tracking parameters act just like they do in Evo
  #
  def link_tracking_parameters_hash
    AnchorHrefTransformer.querystring_to_hash('?' + link_tracking_parameters)
  end

  def link_tracking_parameters
    no_link_tracking_parameters ? '' : read_attribute(:link_tracking_parameters)
  end

  def link_tracking_parameters=(value)
    write_attribute(:link_tracking_parameters, value.try(:strip))
  end

  def no_link_tracking_parameters
    read_attribute(:link_tracking_parameters).nil?
  end

  def destroy
    sms_vendor.destroy if sms_vendor.try(:account_ids) == [self.id]
    email_vendor.destroy if email_vendor.try(:account_ids) == [self.id]
    voice_vendor.destroy if voice_vendor.try(:account_ids) == [self.id]

    # if you put this in a before_destroy, associations get deleted first which breaks things
    # lolz: https://github.com/rails/rails/issues/670
    self.class.connection.unprepared_statement do
      [EmailRecipient, SmsRecipient, VoiceRecipient, CallScript, EmailRecipientClick, EmailRecipientOpen].each do |klass|
        assoc = klass.name.tableize.pluralize
        self.class.connection.delete("DELETE FROM #{assoc} WHERE id IN (#{self.send(assoc).select("#{assoc}.id").except(:order).to_sql})")
      end
    end

    super
  end

  protected

  def create_base_keywords!
    keywords.create!(name: 'default')
    keywords.create!(name: 'start')
    keywords.create!(name: 'stop')
    keywords.create!(name: 'help')
  end

  def generate_sid
    loop do
      self.sid = SecureRandom.hex(16)
      break unless Account.where(sid: self.sid).any?
    end
  end

  def normalize_dcm_account_codes
    if dcm_account_codes
      self.dcm_account_codes = dcm_account_codes.to_set unless dcm_account_codes.is_a?(Set)
      dcm_account_codes.collect!(&:upcase).collect!(&:strip)
    end
  end

  ##
  # Accounts with an email vendor are required to have one (default)
  # from address. This is done as an in-memory validation on purpose -
  # so that unsaved, new accounts can get validated, too.
  #
  def has_one_default_from_address
    unless from_addresses.find_all{|fa| fa.is_default? }.count == 1
      errors.add(:default_from_address, "cannot be nil")
    end
  end

  def has_one_default_from_number
    unless from_numbers.find_all{|fa| fa.is_default? }.count == 1
      errors.add(:default_from_number, "cannot be nil")
    end
  end

  def shared_sms_vendor?
    sms_vendor && sms_vendor.shared?
  end

  def validate_sms_vendor
    if sms_vendor_id_changed? && sms_vendor && sms_vendor.accounts.count > 0 && !sms_vendor.shared?
      errors.add(:shared_vendor, "Vendor specified is not shared and already has one account")
    end
  end

  def validate_sms_prefixes
    if shared_sms_vendor? && sms_prefixes.size < 1
      errors.add(:sms_prefixes, "At least 1 SmsPrefix is required with a shared vendor")
    end
  end

  class KeywordNotFound < StandardError;  end
end
