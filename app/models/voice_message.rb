class VoiceMessage < ActiveRecord::Base
  include Message
  has_one :call_script

  attr_accessible :play_url, :say_text
  validates :play_url, presence: true, unless: ->(message) { message.say_text.present? }, on: :create
  validates :say_text, presence: true, unless: ->(message) { message.play_url.present? }, on: :create

  after_create :create_script

  def create_script
    return unless self.say_text.present?
    self.create_call_script!(say_text: self.say_text)
  end

end
