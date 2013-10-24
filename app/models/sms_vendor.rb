class SmsVendor < ActiveRecord::Base
  include Vendor
  include PhoneVendor

  attr_accessible :help_text, :stop_text

  DEFAULT_HELP_TEXT = "Go to http://bit.ly/govdhelp for help"
  DEFAULT_STOP_TEXT = "You will no longer receive SMS messages."
  RESERVED_KEYWORDS = %w(stop quit help)

  has_many :keywords, :foreign_key => 'vendor_id', :dependent => :destroy
  has_many :stop_requests, :foreign_key => 'vendor_id', :dependent => :delete_all
  has_many :inbound_messages, :inverse_of => :vendor, :foreign_key => 'vendor_id', :order => "#{InboundMessage.table_name}.created_at DESC", :dependent => :delete_all
  has_many :sms_prefixes, :dependent => :destroy

  validates_presence_of [:help_text, :stop_text]
  validates_inclusion_of :shared, :in => [true, false]
  validates_length_of [:help_text, :stop_text], :maximum => 160
  validates_uniqueness_of :from_phone

  def create_keyword!(options)
    kw = self.keywords.build
    kw.account = options[:account]
    kw.name = options[:name]
    self.save!
    kw
  end

  def receive_message!(options)
    inbound_messages.create!(options)
  end

  def stop!(command_parameters)
    # we need to maintain a blacklist at the vendor (i.e. short-code) level
    stop_requests.create(phone: command_parameters.from)
    # ...and we need to execute account-specific stop commands
    accounts.each { |a| a.stop(command_parameters) }
  end
end
