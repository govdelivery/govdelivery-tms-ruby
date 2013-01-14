class SmsVendor < ActiveRecord::Base
  include Vendor
  include PhoneVendor

  attr_accessible :help_text, :stop_text

  DEFAULT_HELP_TEXT = "Go to http://bit.ly/govdhelp for help"
  DEFAULT_STOP_TEXT = "You will no longer receive SMS messages."
  RESERVED_KEYWORDS = %w(stop quit help)

  has_many :keywords, :foreign_key => 'vendor_id'
  has_many :stop_requests, :foreign_key => 'vendor_id'
  has_many :inbound_messages, :inverse_of => :vendor, :foreign_key => 'vendor_id'

  validates_presence_of [:help_text, :stop_text]
  validates_length_of [:help_text, :stop_text], :maximum => 160

  def create_keyword!(options)
    kw = self.keywords.build
    kw.account = options[:account]
    kw.name = options[:name]
    self.save!
    kw
  end

  def receive_message!(options)
    self.inbound_messages.create!(options.except(:stop?))
    stop!(options[:from]) if options[:stop?]
  end

  private

  def stop!(from)
    # we need to maintain a blacklist at the vendor (i.e. short-code) level
    stop_request = stop_requests.find_or_create_by_phone(from)
    stop_request.save!
    # ...and we need to execute account-specific stop commands
    accounts.each { |a| a.stop(:from => from) }
  end
end
