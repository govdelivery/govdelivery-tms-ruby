#
# Before saving, recipient tries to properly format the 
# provided phone attribute into the formatted_phone attribute. 
#
# A recipient without a formatted_phone is one that we 
# cannot possibly forward on to the third-party provider. 
#
class Recipient < ActiveRecord::Base
  attr_accessible :phone, :vendor

  unless defined? STATUS_NEW
    STATUS_NEW = 1
    STATUS_SENDING = 2
    STATUS_SENT = 3
    STATUS_FAILED = 4
    STATUS_BLACKLISTED = 5
  end

  belongs_to :message
  belongs_to :vendor

  scope :incomplete, where(:sent_at => nil)
  scope :blacklisted, joins('inner join stop_requests on stop_requests.vendor_id = recipients.vendor_id and stop_requests.phone = recipients.formatted_phone').readonly(false)

  scope :to_send, -> { incomplete.not_blacklisted.with_valid_phone_number }

  before_validation :truncate_error_message

  validates_length_of :ack, :maximum => 256
  validates_length_of :phone, :maximum => 256
  validates_length_of :formatted_phone, :maximum => 256
  validates_presence_of :phone, :vendor
  validates_uniqueness_of :phone, :scope => 'message_id', :message => 'has already been associated with this message'

  def phone=(ph)
    super
    self.formatted_phone = PhoneNumber.new(ph.to_s).e164
  end

  def complete!(status, ack=nil, error=nil)
    self.ack = ack
    case status
      when 'queued', 'sending'
        self.status = Recipient::STATUS_SENDING
        self.sent_at = Time.now
      when 'sent'
        self.status = Recipient::STATUS_SENT
      when 'failed'
        self.status = Recipient::STATUS_FAILED
        self.completed_at = Time.now
      else
        self.status = Recipient::STATUS_NEW
    end
    self.error_message = error
    self.save!
  end

  private

  def truncate_error_message
    self.error_message.truncate(512) if self.error_message
  end

  def self.not_blacklisted
    joins('left outer join stop_requests on stop_requests.vendor_id = recipients.vendor_id and stop_requests.phone = recipients.formatted_phone').where('stop_requests.phone is null').readonly(false)
  end

  def self.with_valid_phone_number
    where('recipients.formatted_phone is not null')
  end
end
