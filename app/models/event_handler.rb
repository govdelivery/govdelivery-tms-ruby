class EventHandler < ActiveRecord::Base
  has_many :actions, :dependent => :destroy
end
