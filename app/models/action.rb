class Action < ActiveRecord::Base
  belongs_to :account
  belongs_to :event_handler
  serialize :params, ActionParameters

  attr_accessible :account, :action_type, :name, :params
  validates_presence_of :account, :action_type
  validates_length_of :name, :maximum => 255, :allow_nil => true
  validates_length_of :params, :maximum => 4000, :allow_nil => true
  before_save :set_name
  validate :check_action_type

  # Execute this action with the provided options, merging in the actions "params" column.
  def call(action_parameters=ActionParameters.new)
    action_parameters.merge!(self.params)
    action_strategy.call(action_parameters)
  end
  
  # Grab the executable portion of this action
  def action_strategy
    ActionType[self.action_type].callable
  end

  # The name of this action's type.
  def action_type_name
    ActionType[self.action_type].name.to_s
  end

  def to_s
    "#<#{self.class.name}:#{self.object_id}> #{ActionType[self.action_type]}"
  end

  private
  def set_name
    if self.name.nil? || self.action_type_changed?
      self.name = action_type_name
    end
  end

  def check_action_type
    errors.add(:action_type, 'does not exist') unless ActionType[self.action_type]
  end
end