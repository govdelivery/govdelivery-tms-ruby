class User < ActiveRecord::Base
  attr_accessible :email
  
  belongs_to  :account
  validates_presence_of :account
  validates_presence_of :email
  validates_length_of :email, :maximum => 256
  validates_uniqueness_of :email
      
  has_many :messages
  
  before_validation :downcase_email
  
  delegate :vendor, :to => :account
  
  def self.authenticate(email, password)
    User.find_by_email(email.downcase) if email
  end

  private
  def downcase_email
    self.email.downcase! if self.email
  end
end