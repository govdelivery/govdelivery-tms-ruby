class VoiceMessage < ActiveRecord::Base
  include Message
  has_one :call_script
  has_many :voice_recipient_attempts

  attr_accessible :play_url, :say_text, :retries, :retry_delay, :from_number

  validates :play_url, presence: true, unless: ->(message) { message.say_text.present? }, on: :create
  validates :say_text, presence: true, unless: ->(message) { message.play_url.present? }, on: :create

  before_validation :set_from_number
  validate :from_number_allowed?
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

  def recipient_detail_counts
    last_status = voice_recipient_attempts.select('voice_recipient_id, max(completed_at) complete').group('voice_recipient_id')
    secondary_groups = voice_recipient_attempts.select('description, count(description) the_count').where('(voice_recipient_id, completed_at) in (?)', last_status).group('description')
    h = Hash[secondary_groups.map { |r| [r.description, r.the_count] }]
    Hash[%w(busy no_answer human machine).map { |s| [s, 0] }].merge(h)
  end

  protected

  def status_with_attempts(status)
    recipients.send(status).includes(:voice_recipient_attempts)
  end

  def from_number_allowed?
    unless account.from_number_allowed?(self.from_number)
      errors.add(:from_number, "is not authorized to send on this account")
    end
  end

  def set_from_number
    if from_number.nil? && account
      self.from_number = account.from_number
    end
  end
end
