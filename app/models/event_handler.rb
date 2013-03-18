class EventHandler < ActiveRecord::Base
  # Keywords have Commands than can be bound to them, but Commands can also be bound at the Account level and
  # invoked arbitrarily.

  has_many :commands, :dependent => :destroy

  # These are optional, but at least one should be present
  has_one :keyword, :dependent => :destroy
  has_one :account, :dependent => :destroy
end
