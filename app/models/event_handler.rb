class EventHandler < ActiveRecord::Base
  has_many :commands, :dependent => :destroy
end
