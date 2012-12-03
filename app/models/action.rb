class Action < ActiveRecord::Base
  DCM_UNSUBSCRIBE = 1
  DCM_SUBSCRIBE = 2

  ACTION_TYPES = {
    DCM_UNSUBSCRIBE => ->(params){ DcmUnsubscribeWorker.perform_async(params) },
    DCM_SUBSCRIBE => ->(params){ DcmSubscribeWorker.perform_async(params) }
  }

  belongs_to :account
  belongs_to :event_handler

  attr_accessible :account, :action_type, :name, :params
  validates_presence_of :account, :action_type
  validates_length_of :name, :maximum => 255, :allow_nil => true
  validates_length_of :params, :maximum => 4000, :allow_nil => true

  def call(options={})
    action_strategy.call(options.merge(:params => self.params))
  end
  
  def action_strategy
    ACTION_TYPES[self.action_type]
  end
end
