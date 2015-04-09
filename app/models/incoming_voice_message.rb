class IncomingVoiceMessage < ActiveRecord::Base
  belongs_to :from_number
  delegate :account, to: :from_number

  attr_accessible :play_url, :say_text, :is_default, :expires_in

  validates :play_url,   presence: true, unless: ->(message) { message.say_text.present? }, on: :create
  validates :say_text,   presence: true, unless: ->(message) { message.play_url.present? }, on: :create
  validates :expires_in, presence: true, unless: ->(message) { message.is_default? }, on: :create

  def is_expired?
    created_at + expires_in.seconds < Time.zone.now
  end

  delegate :phone_number, to: :from_number
end
