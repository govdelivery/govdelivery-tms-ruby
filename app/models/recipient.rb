#
# Before saving, recipient tries to properly format the 
# provided phone attribute into the formatted_phone attribute. 
#
# A recipient without a formatted_phone is one that we 
# cannot possibly forward on to the third-party provider. 
#
class Recipient < ActiveRecord::Base  
  attr_accessible :phone, :vendor

  unless defined? STATUS_NEW
    STATUS_NEW = 1
    STATUS_SENDING = 2
    STATUS_SENT = 3
    STATUS_FAILED = 4
  end
  
  belongs_to :message
  belongs_to :vendor
  
  scope :incomplete,  lambda { where(:sent_at => nil) }

  # If the number is plausible, format it and copy it into the phone field. 
  phony_normalize :phone, :as => :formatted_phone, :default_country_code => 'US' 
 
  before_validation :truncate_error_message
  before_save :format_phone

  validates_length_of :ack, :maximum => 256
  validates_length_of :phone, :maximum => 256
  validates_length_of :formatted_phone, :maximum => 256
  validates_presence_of :phone, :vendor
  validates_uniqueness_of :phone, :scope => "message_id", :message => "has already been associated with this message" 

  private  
  
  # Essentially, this adds a "+" in front of the number to force it into E.164 format
  def format_phone
    self.formatted_phone = Phony.formatted(self.formatted_phone, :spaces => '') unless self.formatted_phone.nil? 
  end

  def truncate_error_message
    self.error_message.truncate(512) if self.error_message
  end
end
