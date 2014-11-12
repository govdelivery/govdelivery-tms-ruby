class SmsVendor < ActiveRecord::Base
  include Vendor
  include PhoneVendor

  has_many :stop_requests, :foreign_key => 'vendor_id', :dependent => :delete_all
  has_many :inbound_messages, -> { order("#{InboundMessage.table_name}.created_at DESC") }, :inverse_of => :vendor, :foreign_key => 'vendor_id', :dependent => :delete_all
  has_many :sms_prefixes, :dependent => :destroy

  validates_inclusion_of :shared, :in => [true, false]
  validates_uniqueness_of :from_phone
  validates_uniqueness_of :name

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
    stop_requests.where(phone: command_parameters.from).delete_all #its ok if it doesn't exist
    accounts.each { |a| a.start(command_parameters) }
  end

  def delivery_mechanism
    Service::TwilioClient::Sms.new(username, password)
  end
end
