class Recipient < ActiveRecord::Base  
  attr_accessible :phone, :country_code

  belongs_to  :message
  
  scope :incomplete,  lambda { where(:ack => nil) }

  before_validation :format_phone
  validates_length_of :ack, :maximum => 256
  validates_numericality_of :country_code, :only_integer => true
  validates_length_of :country_code, :maximum => 4
  validates_numericality_of :phone, :only_integer => true
  validates_length_of :phone, :maximum => 11
  validates_uniqueness_of :phone, :scope => "message_id", :message => "has already been associated with this message" 

  private  
  def format_phone
    self.phone.gsub!(/\D/,'') if self.phone
    self.country_code.gsub!(/\D/,'') if self.country_code
    self.country_code = '1' if self.country_code.blank?
  end
end
