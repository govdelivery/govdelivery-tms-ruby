class VoiceMessage < ActiveRecord::Base
  include Message
  has_one :call_script
  has_many :voice_recipient_attempts

  attr_accessible :play_url, :say_text, :retries, :retry_delay
  validates :play_url, presence: true, unless: ->(message) { message.say_text.present? }, on: :create
  validates :say_text, presence: true, unless: ->(message) { message.play_url.present? }, on: :create

  after_create :create_script

  def create_script
    return unless self.say_text.present?
    self.create_call_script!(say_text: self.say_text)
  end

  def recipients_who_human
    Kaminari.paginate_array(status_with_attempts('sent').select { |recip| recip.secondary_status == 'human' })
  end

  def recipients_who_machine
    Kaminari.paginate_array(status_with_attempts('sent').select { |recip| recip.secondary_status == 'machine' })
  end

  def recipients_who_busy
    Kaminari.paginate_array(status_with_attempts('failed').select { |recip| recip.secondary_status == 'busy' })
  end

  def recipients_who_no_answer
    Kaminari.paginate_array(status_with_attempts('failed').select { |recip| recip.secondary_status == 'no_answer' })
  end

  protected

  def status_with_attempts(status)
    recipients.send(status).includes(:voice_recipient_attempts)
  end
end
