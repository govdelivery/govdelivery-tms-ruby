require 'active_record'
require File.expand_path('../../concerns/message', __FILE__)

class VoiceMessage < ActiveRecord::Base
  include Message

  attr_accessible :play_url
  validates_presence_of :play_url

  def sending!
    super
    self.recipients_sending!
  end

end
