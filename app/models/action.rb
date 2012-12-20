class Action < ActiveRecord::Base
  DCM_UNSUBSCRIBE = 1 # :params => "DCM_ACCOUNT_CODE_1,DCM_ACCOUNT_CODE_2,..."
  DCM_SUBSCRIBE   = 2 # :params => "DCM_ACCOUNT_CODE:TOPIC_CODE1,TOPIC_CODE2"
  FORWARD         = 3 # :params => "GET http://example.com"
  
  ACTION_TYPES = {
    DCM_UNSUBSCRIBE => {:name => :dcm_unsubscribe, :callable => ->(params){ DcmUnsubscribeWorker.perform_async(params.to_hash) }},
    DCM_SUBSCRIBE   => {:name => :dcm_subscribe,   :callable => ->(params){ DcmSubscribeWorker.perform_async(params.to_hash) }},
    FORWARD         => {:name => :forward,         :callable => ->(params){ ForwardWorker.perform_async(params.to_hash)}}
  }

  belongs_to :account
  belongs_to :event_handler

  attr_accessible :account, :action_type, :name, :params
  validates_presence_of :account, :action_type
  validates_length_of :name, :maximum => 255, :allow_nil => true
  validates_length_of :params, :maximum => 4000, :allow_nil => true
  before_save :set_name

  # Execute this action with the provided options, merging in the actions "params" column.
  def call(action_parameters=ActionParameters.new)
    action_parameters.params = self.params
    action_strategy.call(action_parameters)
  end
  
  # Grab the executable portion of this action
  def action_strategy
    ACTION_TYPES[self.action_type][:callable]
  end

  # The name of this action's type.
  def action_type_name
    ACTION_TYPES[self.action_type][:name].to_s
  end

  def to_s
    "#<#{self.class.name}:#{self.object_id}> #{ACTION_TYPES[self.action_type]}"
  end

  private
  def set_name
    if self.name.nil? || self.action_type_changed?
      self.name = action_type_name
    end
  end
end
