class VoiceMessage < ActiveRecord::Base
  include PhoneMessage

  attr_accessible :play_url
  validates_presence_of :play_url

end