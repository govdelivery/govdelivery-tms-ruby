class Command < ActiveRecord::Base
  belongs_to :account
  belongs_to :event_handler
  serialize :params, CommandParameters

  attr_accessible :command_type, :name, :params
  validates_presence_of :account, :command_type
  validates_length_of :name, :maximum => 255, :allow_nil => true
  validates :params, length: {maximum: 4000}, :allow_nil => true
  before_save :set_name
  validate :validate_command

  delegate :process_response, :to => :command_strategy

  has_many :command_actions, dependent: :nullify

  # Execute this command with the provided options, merging in the commands "params" column.
  def call(command_parameters=CommandParameters.new)
    command_parameters.merge!(self.params)
    command_strategy.invoke!(command_parameters)
  end

  # Grab the executable portion of this command
  def command_strategy
    CommandType[self.command_type]
  end

  # The name of this command's type.                                  s
  def command_type_name
    CommandType[self.command_type].name.to_s
  end

  def to_s
    "#<#{self.class.name}:#{self.object_id}> #{CommandType[self.command_type]}"
  end

  def params=(command_parameters)
    command_parameters = CommandParameters.new(command_parameters) unless command_parameters.is_a?(CommandParameters)
    super(command_parameters)
  end

  protected

  def build_response(short_body, dest_number)
    message = account.sms_messages.new(:body => short_body)
    # User is out of context for this message, as there is no current user - the
    # incoming controller request was from a handset (not a client's app)
    message.recipients.build(:phone => dest_number, :vendor => account.sms_vendor)
    message.save!
    message
  end

  # Copies the name from the command unless it was specified explicitly. 
  def set_name
    if self.name.nil? || (self.command_type_changed? && !self.command_type_was.nil?)
      self.name = command_type_name
    end
  end

  def validate_command
    return unless account
    if !(CommandType[self.command_type.to_sym] rescue nil)
      errors.add(:command_type, 'is invalid')
    elsif (cmd_errors = CommandType[self.command_type].validate_params(params, self.account)).any?
      errors.add(:params, "has invalid #{self.command_type} parameters: #{cmd_errors.full_messages.join(', ')}")
    end
    errors.empty?
  end

end