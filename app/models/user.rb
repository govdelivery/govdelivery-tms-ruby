class User < ActiveRecord::Base
  devise :database_authenticatable, :validatable

  attr_accessible :email, :password
  
  belongs_to  :account
  validates_presence_of :account
  validates_presence_of :email
  validates_length_of :email, :maximum => 256
  validates_uniqueness_of :email
      
  has_many :messages, :order => 'messages.created_at DESC'
  has_many :account_messages, :through=>:account, :source=>:messages
  
  before_validation :downcase_email
  
  delegate :vendors, :to => :account
  delegate :sms_vendor, :to => :account
  delegate :voice_vendor, :to => :account
  
  def self.authenticate(email, password)
    User.find_by_email(email.downcase) if email
  end

  def new_message(params)
    messages.new(params).tap do |m|
      m.account = self.account
    end
  end

  private
  def downcase_email
    self.email.downcase! if self.email
  end
end