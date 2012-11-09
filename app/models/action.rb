class Action < ActiveRecord::Base
  ACTION_TYPES = {
    1 => ActionType::DCMUnsubscribe
  }

  belongs_to :account
  belongs_to :keyword

  attr_accessible :account, :keyword, :action_type, :name, :params
  validates_presence_of :account, :keyword, :action_type
  validates_length_of :name, :maximum => 255, :allow_nil => true
  validates_length_of :params, :maximum => 4000, :allow_nil => true

  def execute(options={})
    action_type_instance.execute(options.merge(:params => self.params))
  end
  
  def action_type_instance
    ACTION_TYPES[self.action_type].new
  end
end
