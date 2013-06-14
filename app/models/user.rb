class User < ActiveRecord::Base
  devise :database_authenticatable, :validatable, :token_authenticatable

  attr_accessible :email, :password

  belongs_to :account
  validates_presence_of :account
  validates_presence_of :email
  validates_length_of :email, :maximum => 256
  validates_uniqueness_of :email

  has_many :email_messages, :order => 'email_messages.created_at DESC'
  has_many :account_email_messages, :through => :account, :source => EmailMessage.table_name
  has_many :sms_messages, :order => 'sms_messages.created_at DESC'
  has_many :account_sms_messages, :through => :account, :source => SmsMessage.table_name
  has_many :voice_messages, :order => 'voice_messages.created_at DESC'
  has_many :account_voice_messages, :through => :account, :source => VoiceMessage.table_name

  before_validation :downcase_email
  before_save :ensure_authentication_token
  
  delegate :vendors, :to => :account
  delegate :sms_vendor, :to => :account
  delegate :voice_vendor, :to => :account

  def self.authenticate(email, password)
    User.find_by_email(email.downcase) if email
  end

  def self.with_token(token)
    self.find_by_authentication_token(token)
  end
  
  private
  def downcase_email
    self.email.downcase! if self.email
  end
end