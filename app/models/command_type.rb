class CommandType#= Struct.new(:name, :fields, :callable) do
  attr_accessor :name, :fields, :callable, :array_fields

  def initialize(name, fields, array_fields, callable)
    self.name = name
    self.fields = fields
    self.array_fields = array_fields
    self.callable = callable
  end

  def all_fields
    fields + array_fields
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

  def validate_params(command_params)
    command_params = CommandParameters.new(command_params) unless command_params.is_a?(CommandParameters)
    invalid_fields = fields.select{|f| command_params.send(f).blank?}
    invalid_fields.concat(array_fields.select{|f| !command_params.send(f).is_a?(Array)})
    invalid_fields
  end
end

CommandType.create(:dcm_unsubscribe, [], [:dcm_account_codes],                       ->(params){ DcmUnsubscribeWorker.perform_async(params.to_hash) })
CommandType.create(:dcm_subscribe,   [:dcm_account_code], [:dcm_topic_codes],      ->(params){ DcmSubscribeWorker.perform_async(params.to_hash) })
CommandType.create(:forward,         [:http_method, :username, :password, :url], [], ->(params){ ForwardWorker.perform_async(params.to_hash) })