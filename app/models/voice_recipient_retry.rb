class VoiceRecipientRetry < ActiveRecord::Base
  belongs_to :voice_message
  belongs_to :voice_recipient

  validates_presence_of :voice_message
  validates_presence_of :voice_recipient
  validates_presence_of :status
end