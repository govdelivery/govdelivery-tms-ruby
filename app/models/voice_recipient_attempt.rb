class VoiceRecipientAttempt < ActiveRecord::Base
  belongs_to :voice_message
  belongs_to :voice_recipient

  attr_accessible :ack, :description
  validates_presence_of :ack, :description, :voice_message, :voice_recipient
end