class SmsMessage < ActiveRecord::Base
  include Message

  validates_length_of :body, :maximum => 160
  attr_accessible :body

end
