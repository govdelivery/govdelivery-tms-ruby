class IncomingVoiceMessage < ActiveRecord::Base
  belongs_to :from_number
  delegate :account, to: :from_number

  attr_accessible :play_url, :say_text, :is_default

  validates :play_url, presence: true, unless: ->(message) { message.say_text.present? }, on: :create
  validates :say_text, presence: true, unless: ->(message) { message.play_url.present? }, on: :create
end
