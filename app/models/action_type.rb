class ActionType#= Struct.new(:name, :fields, :callable) do
  attr_accessor :name, :fields, :callable

  def initialize(name, fields, callable)
    self.name = name
    self.fields = fields
    self.callable = callable
  end

  ACTION_TYPES = HashWithIndifferentAccess.new

  def self.[](type)
    ACTION_TYPES[type]
  end

  def self.all
    ACTION_TYPES
  end

  def self.create(*args)
    new(*args).tap do |i|
      ACTION_TYPES[i.name] = i
    end
  end
end

ActionType.create(:dcm_unsubscribe, [:dcm_account_codes],                       ->(params){ DcmUnsubscribeWorker.perform_async(params.to_hash) })
ActionType.create(:dcm_subscribe,   [:dcm_account_code, :dcm_topic_codes],      ->(params){ DcmSubscribeWorker.perform_async(params.to_hash) })
ActionType.create(:forward,         [:http_method, :username, :password, :url], ->(params){ ForwardWorker.perform_async(params.to_hash) })