class VoiceMessage < ActiveRecord::Base
  include Message
  has_one :call_script
  has_many :voice_recipient_retries

  attr_accessible :play_url, :say_text, :retries, :retry_delay
  validates :play_url, presence: true, unless: ->(message) { message.say_text.present? }, on: :create
  validates :say_text, presence: true, unless: ->(message) { message.play_url.present? }, on: :create

  after_create :create_script

  def create_script
    return unless self.say_text.present?
    self.create_call_script!(say_text: self.say_text)
  end

  def recipients_who_human
    Kaminari.paginate_array(recipients.sent.select { |recip| recip.secondary_status == 'human' })
  end

  def recipients_who_machine
    Kaminari.paginate_array(recipients.sent.select { |recip| recip.secondary_status == 'machine' })
  end

  def recipients_who_busy
    Kaminari.paginate_array(recipients.sent.select { |recip| recip.secondary_status == 'busy' })
  end

  def recipients_who_no_answer
    Kaminari.paginate_array(recipients.sent.select { |recip| recip.secondary_status == 'no_answer' })
  end

  def recipient_state_counts
    secondary_groups = recipients.select('count(secondary_status) the_count, secondary_status').where('secondary_status is not NULL').group('secondary_status').reorder('')
    h = super.merge!(Hash[secondary_groups.map { |r| [r.secondary_status, r.the_count] }])
    Hash[%w(busy no_answer human machine).map { |s| [s, 0] }].merge(h)
  end
end
