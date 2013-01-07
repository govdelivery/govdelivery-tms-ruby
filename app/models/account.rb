class Account < ActiveRecord::Base
  attr_accessible :name, :vendors, :vendor
  
  has_many :users
  has_many :account_vendors
  has_many :vendors, :through => :account_vendors
  has_many :messages
  has_many :keywords
    
  belongs_to :stop_handler, :class_name => 'EventHandler'
  validate :ensure_unique_vendors
  
  validates_presence_of :name
  
  validates_length_of :name, :maximum => 256

  before_create :create_stop_handler!

  def add_action!(params)
    unless stop_handler
      self.create_stop_handler!
      self.save!
    end
    stop_handler.actions.create!({:account => self}.merge(params))
  end

  def stop(params={})
    stop_handler.actions.each{|a| a.call(params)} if stop_handler
  end
  
  def vendor=(vendor)
    vendors=[vendor]
  end
  
  def ensure_unique_vendors
    if Hash[vendors.group_by(&:vtype)].values.map(&:length).max.to_i > 1
       errors.add(:vendors, "must be of different type") 
    end
  end

  def sms_vendor
    vendors.select(&:sms?).first
  end

  def voice_vendor
    vendors.select(&:voice?).first
  end

  def email_vendor
    vendors.select(&:email?).first
  end
end
