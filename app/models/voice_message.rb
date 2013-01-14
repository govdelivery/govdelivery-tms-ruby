class VoiceMessage < ActiveRecord::Base
  include Message

  attr_accessible :play_url
  validates_presence_of :play_url

end