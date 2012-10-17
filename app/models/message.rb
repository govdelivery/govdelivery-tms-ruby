class Message < ActiveRecord::Base
  attr_accessible :recipients, :short_body, :ack, :completed
end
