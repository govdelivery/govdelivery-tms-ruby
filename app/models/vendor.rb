class Vendor < ActiveRecord::Base
  attr_accessible :name, :username, :password, :from, :worker, :help_text, :stop_text, :voice, :vtype

  enum :vtype, [:sms, :voice, :email]

  DEFAULT_HELP_TEXT = "Go to http://bit.ly/govdhelp for help"
  DEFAULT_STOP_TEXT = "You will no longer receive SMS messages."
  RESERVED_KEYWORDS = %w(stop quit help)

  has_many :keywords
  has_many :account_vendors
  has_many :accounts, :through => :account_vendors
  has_many :stop_requests
  has_many :inbound_messages, :include => :vendor
  has_many :recipients

  before_validation :infer_vtype
  validates_presence_of [:name, :username, :password, :from, :worker, :help_text, :stop_text, :vtype]

  validates_uniqueness_of :name
  validates_length_of [:name, :username, :password, :from, :worker], :maximum => 256
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

  def infer_vtype
    self.vtype ||= worker.constantize.vendor_type
  end

  def stop!(from)
    # we need to maintain a blacklist at the vendor (i.e. short-code) level
    stop_request = stop_requests.find_or_create_by_phone(from)
    stop_request.save!
    # ...and we need to execute account-specific stop actions
    accounts.each { |a| a.stop(:from => from) }
  end
end
