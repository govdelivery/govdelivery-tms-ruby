class CommandType#= Struct.new(:name, :fields, :callable) do
  attr_accessor :name, :fields, :callable

  def initialize(name, fields, callable)
    self.name = name
    self.fields = fields
    self.callable = callable
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
end

CommandType.create(:dcm_unsubscribe, [:dcm_account_codes],                       ->(params){ DcmUnsubscribeWorker.perform_async(params.to_hash) })
CommandType.create(:dcm_subscribe,   [:dcm_account_code, :dcm_topic_codes],      ->(params){ DcmSubscribeWorker.perform_async(params.to_hash) })
CommandType.create(:forward,         [:http_method, :username, :password, :url], ->(params){ ForwardWorker.perform_async(params.to_hash) })