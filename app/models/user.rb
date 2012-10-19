class User < ActiveRecord::Base
  attr_accessible :username
  
  belongs_to  :account
  validates_presence_of :account
  validates_presence_of :username
  validates_length_of :username, :maximum => 256
  validates_uniqueness_of :username
      
  has_many :messages
  
  before_validation :downcase_username
  
  delegate :vendor, :to => :account
  
  def self.authenticate(username, password)
    User.find_by_username(username.downcase) if username
  end

  private
  def downcase_username
    self.username.downcase! if self.username
  end
end