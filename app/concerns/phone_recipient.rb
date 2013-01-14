module PhoneRecipient
  extend ActiveSupport::Concern

  included do
    include Recipient
    attr_accessible :phone, :vendor

    scope :incomplete, where(:sent_at => nil)
    scope :sending, where(:status => RecipientStatus::STATUS_SENDING)
    scope :blacklisted, joins('inner join stop_requests on stop_requests.vendor_id = recipients.vendor_id and stop_requests.phone = recipients.formatted_phone').readonly(false)

    scope :to_send, -> { incomplete.not_blacklisted.with_valid_phone_number }

    before_validation :truncate_error_message

    validates_length_of :ack, :maximum => 256
    validates_length_of :phone, :maximum => 256
    validates_length_of :formatted_phone, :maximum => 256
    validates_presence_of :phone
    validates_uniqueness_of :phone, :scope => 'message_id', :message => 'has already been associated with this message'

    def phone=(ph)
      super
      self.formatted_phone = PhoneNumber.new(ph.to_s).e164
    end

    def complete!(attrs)
      self.vendor = message.vendor
      self.ack = attrs[:ack]
      self.status = attrs[:status] unless attrs[:status].blank?
      self.error_message = attrs[:error_message]
      #sent, new mean don't set sent_at
      self.sent_at = Time.now if [RecipientStatus::STATUS_SENT, RecipientStatus::STATUS_NEW].include?(self.status)
      self.completed_at = Time.now
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

end
