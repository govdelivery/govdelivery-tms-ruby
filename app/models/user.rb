class User < ActiveRecord::Base
  devise :database_authenticatable, :validatable

  attr_accessible :email, :password
  
  belongs_to  :account
  validates_presence_of :account
  validates_presence_of :email
  validates_length_of :email, :maximum => 256
  validates_uniqueness_of :email

  has_many :sms_messages, :order => 'sms_messages.created_at DESC'
  has_many :account_sms_messages, :through=>:account, :source=>:sms_messages
  has_many :voice_messages, :order => 'voice_messages.created_at DESC'
  has_many :account_voice_messages, :through=>:account, :source=>:voice_messages
  
  before_validation :downcase_email
  
  delegate :vendors, :to => :account
  delegate :sms_vendor, :to => :account
  delegate :voice_vendor, :to => :account
  
  def self.authenticate(email, password)
    User.find_by_email(email.downcase) if email
  end

  private
  def downcase_email
    self.email.downcase! if self.email
  end
end