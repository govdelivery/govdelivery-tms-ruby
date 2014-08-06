class CallScript < ActiveRecord::Base
  belongs_to :voice_message
  attr_accessible :say_text

  validates :say_text, presence: true
  validates :voice_message, presence: true
end
