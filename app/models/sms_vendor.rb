class SmsVendor < ActiveRecord::Base
  include Vendor
  include PhoneVendor

  attr_accessible :help_text, :stop_text

  # set default_response_text in order to respond to anything.
  # it could be set to DEFAULT_HELP_TEXT
  # it can be set to nil to _not_ respond to anything , like if a forward command is set to respond to anything

  DEFAULT_HELP_TEXT = "Go to http://bit.ly/govdhelp for help"
  DEFAULT_STOP_TEXT = "You will no longer receive SMS messages."
  DEFAULT_START_TEXT = "Welcome to GovDelivery SMS Alerts. Msg&data rates may apply. Reply HELP for help, STOP to cancel. http://govdelivery.com/wireless for more help. 5 msg/wk."
  RESERVED_KEYWORDS = %w(stop quit help)

  has_many :keywords, :foreign_key => 'vendor_id', :dependent => :destroy
  has_many :stop_requests, :foreign_key => 'vendor_id', :dependent => :delete_all
  has_many :inbound_messages, :inverse_of => :vendor, :foreign_key => 'vendor_id', :order => "#{InboundMessage.table_name}.created_at DESC", :dependent => :delete_all
  has_many :sms_prefixes, :dependent => :destroy

  validates_presence_of [:help_text, :stop_text]
  validates_inclusion_of :shared, :in => [true, false]
  validates_length_of [:help_text, :stop_text], :maximum => 160
  validates_uniqueness_of :from_phone

  has_one :help_keyword,    class_name: Keywords::VendorHelp, :foreign_key => 'vendor_id'
  has_one :stop_keyword,    class_name: Keywords::VendorStop, :foreign_key => 'vendor_id'
  has_one :default_keyword, class_name: Keywords::VendorDefault, :foreign_key => 'vendor_id'
  # this info needs to be kept in the database for configurability and trackability
  after_save( :create_stop_keyword!, if: ->{ self.stop_keyword.nil?} )
  after_save( :create_help_keyword!, if: ->{ self.help_keyword.nil?} )
  after_save( :create_default_keyword!, if: ->{ self.default_keyword.nil?} )


  def create_keyword!(options)
    kw = self.keywords.build
    kw.account = options[:account]
    kw.name = options[:name]
    kw.save!
    kw
  end

  def create_command!(keyword_name, params)
    keyword = keywords.where(name: keyword_name).first_or_create!
    keyword.create_command!(params)
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

  def delivery_mechanism
    Service::TwilioClient::Sms.new(username, password)
  end
end
