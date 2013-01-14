module PhoneRecipient
  extend ActiveSupport::Concern

  included do
    include Recipient
    attr_accessible :phone, :vendor

    scope :incomplete, where(:sent_at => nil)
    scope :sending, where(:status => RecipientStatus::STATUS_SENDING)
    scope :blacklisted, joins("inner join #{StopRequest.table_name} on #{StopRequest.table_name}.vendor_id = #{self.table_name}.vendor_id and #{StopRequest.table_name}.phone = #{self.table_name}.formatted_phone").readonly(false)

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
      # sent_at is when we send the msg to twilio, completed_at is when we finalize it
      self.sent_at ||= Time.now unless RecipientStatus.not_sent?(status)
      self.completed_at ||= Time.now if RecipientStatus.complete?(status)
      self.save!
    end

    private

    def truncate_error_message
      self.error_message.truncate(512) if self.error_message
    end

    def self.not_blacklisted
      joins("left outer join #{StopRequest.table_name} on #{StopRequest.table_name}.vendor_id = #{self.table_name}.vendor_id and #{StopRequest.table_name}.phone =  #{self.table_name}.formatted_phone").where("#{StopRequest.table_name}.phone is null").readonly(false)
    end

    def self.with_valid_phone_number
      where("#{self.table_name}.formatted_phone is not null")
    end
  end

end
