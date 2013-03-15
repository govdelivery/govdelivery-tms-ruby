require 'set'

class CommandType
  attr_accessor :name, :string_fields, :callable, :array_fields

  def initialize(name, string_fields, array_fields, callable)
    self.name = name
    self.string_fields = string_fields
    self.array_fields = array_fields
    self.callable = callable
  end

  def all_fields
    string_fields + array_fields
  end

  ALL = HashWithIndifferentAccess.new

  def self.[](type)
    ALL[type]
  end

  def self.all
    ALL
  end

  def self.create(*args)
    new(*args).tap do |i|
      ALL[i.name] = i
    end
  end

  def validate_params(command_params, account)
    command_params = CommandParameters.new(command_params) unless command_params.is_a?(CommandParameters)
    command_params.command_type = self
    command_params.account = account
    command_params.valid?
    command_params.errors
  end
end

CommandType.create(:dcm_unsubscribe, [], [:dcm_account_codes],                       ->(params){ DcmUnsubscribeWorker.perform_async(params.to_hash) })
CommandType.create(:dcm_subscribe,   [:dcm_account_code], [:dcm_topic_codes],        ->(params){ DcmSubscribeWorker.perform_async(params.to_hash) })
CommandType.create(:forward,         [:http_method, :username, :password, :url], [], ->(params){ ForwardWorker.perform_async(params.to_hash) })