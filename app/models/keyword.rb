class Keyword < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :name, :account
  validates_length_of :name, :maximum => 160
  validates_uniqueness_of :name, :scope => "account_id"

  attr_accessible :name, :account

  has_many :actions

  def execute_actions(params={})
    actions.each{|a| a.execute(params) }
  end
end
