class SmsVendor < ActiveRecord::Base
  include Vendor
  include PhoneVendor

  attr_accessible :stop_text, :help_text, :start_text
  alias_attribute :from, :from_phone
  attr_accessible :from

  has_many :stop_requests, foreign_key: 'vendor_id', dependent: :delete_all
  has_many :inbound_messages, -> { order("#{InboundMessage.table_name}.created_at DESC") }, inverse_of: :vendor, foreign_key: 'vendor_id', dependent: :delete_all
  has_many :sms_prefixes, dependent: :destroy

  validates :shared, inclusion: { in: [true, false] }
  validates :from_phone, uniqueness: true
  validates :name, uniqueness: true
  validates :from, presence: true

  validate :normalize_from_phone

  def create_inbound_message!(options)
    inbound_messages.create!(options)
  end

  def stop!(command_parameters)
    # we need to maintain a blacklist at the vendor (i.e. short-code) level
    stop_requests.create(phone: command_parameters.from)
    # ...and we need to execute account-specific stop commands
    accounts.each { |a| a.stop(command_parameters) }
  end

  def start!(command_parameters)
    stop_requests.where(phone: command_parameters.from).delete_all # its ok if it doesn't exist
    accounts.each { |a| a.start(command_parameters) }
  end

  def delivery_mechanism
    Service::TwilioClient::Sms.new(username, password)
  end

  def normalize_from_phone
    self.from_phone = PhoneNumber.new(from_phone).e164_or_short if from_phone
  end
end
