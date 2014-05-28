require 'set'

class Account < ActiveRecord::Base
  attr_accessible :name, :sms_vendor, :email_vendor, :voice_vendor, :from_address, :dcm_account_codes

  belongs_to :email_vendor
  belongs_to :sms_vendor

  #Temporary
  belongs_to :stop_handler, :class_name => 'EventHandler'
  belongs_to :voice_vendor
  belongs_to :ipaws_vendor, :class_name => 'IPAWS::Vendor'

  has_many :commands
  has_many :email_messages
  has_many :keywords
  has_many :sms_messages
  has_many :sms_prefixes, :inverse_of => :account
  has_many :stop_requests
  has_many :users
  has_many :voice_messages

  has_many :from_addresses, :inverse_of => :account
  has_one :default_from_address, conditions: { is_default: true }, class_name: FromAddress



  has_one :stop_keyword,    class_name: Keywords::AccountStop
  has_one :help_keyword,    class_name: Keywords::AccountHelp
  has_one :default_keyword, class_name: Keywords::AccountDefault
  # special keywords need to be kept in the database for configurability and trackability
  # even non sms accounts get these because who cares
  after_save( :create_stop_keyword!, if: ->{ self.stop_keyword.nil? && self.sms_vendor.present? } )
  after_save( :create_help_keyword!, if: ->{ self.help_keyword.nil? && self.sms_vendor.present? } )
  after_save( :create_default_keyword!, if: ->{ self.default_keyword.nil? && self.sms_vendor.present? } )

  # this is a workaround for something funny happening when saving
  # race condition ? unsure
  def create_stop_keyword!
    build_stop_keyword
    self.stop_keyword.valid?
    self.stop_keyword.save!
  end

  def create_help_keyword!
    build_help_keyword
    self.help_keyword.valid?
    self.help_keyword.save!
  end

  def create_default_keyword!
    build_default_keyword
    self.default_keyword.valid?
    self.default_keyword.save!
  end

  serialize :dcm_account_codes, Set
  delegate :from_email, :reply_to_email, :bounce_email, :reply_to, :errors_to, :to => :default_from_address

  before_validation :normalize_dcm_account_codes

  validates :name, presence: true, length: {maximum: 255}
  validate :has_one_default_from_address, :if => '!email_vendor_id.blank?'
  validate :validate_sms_prefixes

  scope :with_sms, where('sms_vendor_id is not null')

  def create_command!(keyword_name, params)
    keyword = keywords.where(name: keyword_name).first_or_create!
    keyword.create_command!(params)
  end

  def feature_enabled?(feature)
    !!self.send("#{feature}_vendor")
  end

  def stop(command_parameters)
    command_parameters.account_id = self.id
    stop_keyword.commands.each { |a| a.call(command_parameters) }
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

  def help_text
    read_attribute(:help_text) || sms_vendor.try(:help_text)
  end

  def stop_text
    read_attribute(:stop_text) || sms_vendor.try(:stop_text)
  end

  def default_response_text
    read_attribute(:default_response_text) || sms_vendor.try(:default_response_text)
  end

  def from_email_allowed?(email)
    !email.nil? && from_addresses.where("lower(from_email) = ?", email.downcase).count == 1
  end

  protected

  def normalize_dcm_account_codes
    if dcm_account_codes
      self.dcm_account_codes = dcm_account_codes.to_set unless dcm_account_codes.is_a?(Set)
      dcm_account_codes.collect!(&:upcase).collect!(&:strip)
    end
  end

  private

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

  def shared_sms_vendor?
    sms_vendor && sms_vendor.shared?
  end

  def validate_sms_prefixes
    if shared_sms_vendor? && sms_prefixes.size < 1
      errors.add(:sms_prefixes, "At least 1 SmsPrefix is required with a shared vendor")
    end
  end

  class KeywordNotFound < Exception;  end
end
