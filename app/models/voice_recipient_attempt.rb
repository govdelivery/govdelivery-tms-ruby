class VoiceRecipientAttempt < ActiveRecord::Base
  belongs_to :voice_message
  belongs_to :voice_recipient

  attr_accessible :ack, :description
  validates :ack, presence: true
  validates :voice_message, presence: true
  validates :voice_recipient, presence: true
end
