class Command < ActiveRecord::Base
  belongs_to :keyword
  delegate :account, to: :keyword

  # TEMPORARY for data migration
  belongs_to :event_handler

  serialize :params, CommandParameters

  attr_accessible :command_type, :name, :params
  validates :command_type, presence: true
  validates :name, length: {maximum: 255, allow_nil: true}
  validates :params, length: {maximum: 4000}, allow_nil: true
  before_save :set_name
  validate :validate_command
  validate :validate_keyword

  delegate :process_response, to: :command_strategy

  has_many :command_actions, dependent: :nullify

  # Execute this command with the provided options and additional parameters
  def call(command_parameters=CommandParameters.new)
    command_parameters.command_id = id
    command_strategy.perform_async!(command_parameters)
  end

  def process_error(job_params, error_message)
    params.merge!(job_params)
    command_strategy.process_error(params, error_message)
  end

  def process_response(job_params, http_response)
    params.merge!(job_params)
    command_strategy.process_response(account, params, http_response)
  end

  # Grab the executable portion of this command
  def command_strategy
    CommandType[command_type]
  end

  # The name of this command's type.
  def command_type_name
    CommandType[command_type].name.to_s
  end

  def to_s
    "#<#{self.class.name}:#{object_id}> #{CommandType[command_type]}"
  end

  def params=(command_parameters)
    command_parameters = CommandParameters.new(command_parameters) unless command_parameters.is_a?(CommandParameters)
    super(command_parameters)
  end

  protected

  def build_response(short_body, dest_number)
    message = account.sms_messages.new(body: short_body)
    # User is out of context for this message, as there is no current user - the
    # incoming controller request was from a handset (not a client's app)
    message.recipients.build(phone: dest_number, vendor: account.sms_vendor)
    message.save!
    message
  end

  # Copies the name from the command unless it was specified explicitly.
  def set_name
    if name.blank? || (self.command_type_changed? && !command_type_was.nil?)
      self.name = command_type_name
    end
  end

  def validate_command
    return unless keyword && account
    begin
      cmd_errors = CommandType[command_type.to_sym].validate_params(params, account)
      errors.add(:params, "has invalid #{command_type} parameters: #{cmd_errors.full_messages.join(', ')}") if cmd_errors.any?
    rescue NameError
      errors.add(:command_type, 'is invalid')
    end
    errors.empty?
  end

  def validate_keyword
    # ordering is important here
    if keyword.nil?
      errors.add(:keyword, 'keyword required')
    elsif account.nil?
      errors.add(:account, 'account required')
    end
  end
end
