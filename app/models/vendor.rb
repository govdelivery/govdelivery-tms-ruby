class Vendor < ActiveRecord::Base
  attr_accessible :name, :username, :password, :from, :worker, :help_text, :stop_text
  
  DEFAULT_HELP_TEXT = "Go to http://bit.ly/govdhelp for help"
  DEFAULT_STOP_TEXT = "You will no longer receive SMS messages."

  has_many :accounts
  has_many :stop_requests
  has_many :inbound_messages, :include => :vendor
  has_many :recipients
  

  validates_presence_of [:name, :username, :password, :from, :worker, :help_text, :stop_text]

  validates_uniqueness_of :name
  validates_length_of [:name, :username, :password, :from, :worker], :maximum => 256
  validates_length_of [:help_text, :stop_text], :maximum => 160

  def stop!(from)
    stop_request = stop_requests.find_or_create_by_phone(from) # we need to maintain a blacklist at the vendor (i.e. short-code) level
    stop_request.save!
    accounts.each {|a| a.stop(from)}      # ...and we need to execute account-specific stop actions
  end
end
