class Command < ActiveRecord::Base
  belongs_to :account
  belongs_to :event_handler
  serialize :params, CommandParameters

  attr_accessible :command_type, :name, :params
  validates_presence_of :account, :command_type
  validates_length_of :name, :maximum => 255, :allow_nil => true
  validates_length_of :params, :maximum => 4000, :allow_nil => true
  before_save :set_name
  validate :check_command_type

  # Execute this command with the provided options, merging in the commands "params" column.
  def call(command_parameters=CommandParameters.new)
    command_parameters.merge!(self.params)
    command_strategy.call(command_parameters)
  end
  
  # Grab the executable portion of this command
  def command_strategy
    CommandType[self.command_type].callable
  end

  # The name of this command's type.
  def command_type_name
    CommandType[self.command_type].name.to_s
  end

  def to_s
    "#<#{self.class.name}:#{self.object_id}> #{CommandType[self.command_type]}"
  end

  private
  
  # Copies the name from the command unless it was specified explicitly. 
  def set_name
    if self.name.nil? || (self.command_type_changed? && !self.command_type_was.nil?)
      self.name = command_type_name
    end
  end

  def check_command_type
    errors.add(:command_type, 'does not exist') unless CommandType[self.command_type]
  end
end