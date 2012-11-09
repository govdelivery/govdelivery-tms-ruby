class Account < ActiveRecord::Base
  attr_accessible :name, :vendor
  
  has_many :users
  belongs_to :vendor

  has_one :stop_keyword, :class_name => "Keyword", :conditions => {:stop => true}
  validates_presence_of :vendor
  
  validates_presence_of :name
  validates_length_of :name, :maximum => 256

  before_create :create_stop_keyword

  def stop(from)
    stop_keyword.execute_actions(:from => from)
  end

  protected
  
  def create_stop_keyword(*args)
    self.stop_keyword = build_stop_keyword(:name => "STOP")
  end
end
