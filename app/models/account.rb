require 'set'

class Account < ActiveRecord::Base
  attr_accessible :name, :sms_vendor, :email_vendor, :voice_vendor, :from_address, :dcm_account_codes

  belongs_to :email_vendor
  belongs_to :sms_vendor
  belongs_to :stop_handler, :class_name => 'EventHandler'
  belongs_to :voice_vendor

  has_many :commands
  has_many :email_messages
  has_many :keywords
  has_many :sms_messages
  has_many :sms_prefixes, :inverse_of => :account
  has_many :stop_requests
  has_many :users
  has_many :voice_messages

  has_one :from_address

  serialize :dcm_account_codes, Set
  delegate :from_email, :reply_to_email, :bounce_email, :to => :from_address

  before_validation :normalize_dcm_account_codes
  before_create :create_stop_handler!

  validates :name, presence: true, length: {maximum: 255}
  validates :from_address, presence: true, :if => '!email_vendor_id.blank?'
  validates :sms_prefixes, length: { minimum: 1, if: :shared_sms_vendor? }

  def add_command!(params)
    unless stop_handler
      self.create_stop_handler!
      self.save!
    end
    stop_handler.commands.new(params).tap { |c| c.account = self }.save!
  end

  def feature_enabled?(feature)
    !!self.send("#{feature}_vendor")
  end

  def stop(command_parameters)
    command_parameters.account_id = self.id
    stop_handler.commands.each { |a| a.call(command_parameters) } if stop_handler
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
      stop(command_parameters)
    end
  end

  def help_text
    read_attribute(:help_text) || sms_vendor.try(:help_text)
  end

  def stop_text
    read_attribute(:stop_text) || sms_vendor.try(:stop_text)
  end  
  protected

  def normalize_dcm_account_codes
    if dcm_account_codes
      self.dcm_account_codes = dcm_account_codes.to_set unless dcm_account_codes.is_a?(Set)
      dcm_account_codes.collect!(&:upcase).collect!(&:strip)
    end
  end

  private

  def shared_sms_vendor?
    sms_vendor && sms_vendor.shared?
  end
end
