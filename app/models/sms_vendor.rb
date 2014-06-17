class SmsVendor < ActiveRecord::Base
  include Vendor
  include PhoneVendor


  has_many :keywords, :foreign_key => 'vendor_id', :dependent => :destroy
  has_many :stop_requests, :foreign_key => 'vendor_id', :dependent => :delete_all
  has_many :inbound_messages, :inverse_of => :vendor, :foreign_key => 'vendor_id', :order => "#{InboundMessage.table_name}.created_at DESC", :dependent => :delete_all
  has_many :sms_prefixes, :dependent => :destroy

  validates_inclusion_of :shared, :in => [true, false]
  validates_uniqueness_of :from_phone

  has_one :stop_keyword,    class_name: Keywords::VendorStop, :foreign_key => 'vendor_id'
  has_one :start_keyword,   class_name: Keywords::VendorStart, :foreign_key => 'vendor_id'
  has_one :help_keyword,    class_name: Keywords::VendorHelp, :foreign_key => 'vendor_id'
  has_one :default_keyword, class_name: Keywords::VendorDefault, :foreign_key => 'vendor_id'
  # this info needs to be kept in the database for configurability and trackability
  after_save( :create_stop_keyword!, if: ->{ self.stop_keyword.nil?} )
  after_save( :create_start_keyword!, if: ->{ self.start_keyword.nil?} )
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
  end

  def delivery_mechanism
    Service::TwilioClient::Sms.new(username, password)
  end
end
