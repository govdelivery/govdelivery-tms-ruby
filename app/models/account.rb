class Account < ActiveRecord::Base
  attr_accessible :name, :vendor
  
  has_many :users
  belongs_to :vendor

  belongs_to :stop_handler, :class_name => 'EventHandler'
  validates_presence_of :vendor, :name
  
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
end
