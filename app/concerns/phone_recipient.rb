module PhoneRecipient
  extend ActiveSupport::Concern

  included do
    include Recipient
    attr_accessible :phone

    scope :to_send, -> vendor_id { with_valid_phone_number }

    before_validation :truncate_error_message

    validates_length_of :ack, :maximum => 256
    validates :phone, :presence => true, length: {maximum: 256}
    validates_length_of :formatted_phone, :maximum => 256
    validates_uniqueness_of :phone, :scope => 'message_id', :message => 'has already been associated with this message'

    def self.with_valid_phone_number
      where("#{self.table_name}.formatted_phone is not null")
    end
  end

  def phone=(ph)
    super
    self.formatted_phone = PhoneNumber.new(ph.to_s).e164
  end

  private

  def truncate_error_message
    self.error_message.truncate(512) if self.error_message
  end

end
