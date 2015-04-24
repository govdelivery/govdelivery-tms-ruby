module PhoneRecipient
  extend ActiveSupport::Concern

  included do
    include Recipient
    attr_accessible :phone
    self.delivery_timeout = Rails.configuration.twilio_delivery_timeout

    scope :to_send, ->(_vendor_id) {with_valid_phone_number}

    before_validation :truncate_error_message

    validates :ack, length: {maximum: 256}
    validates :phone, presence: true, length: {maximum: 256}
    validates :formatted_phone, length: {maximum: 256}
    validates :phone, uniqueness: {scope: 'message_id', message: 'has already been associated with this message'}

    scope :to_poll, lambda {
      min_age = Rails.configuration.twilio_minimum_polling_age.ago
      max_age = delivery_timeout.ago
      incomplete.where("#{quoted_table_name}.created_at BETWEEN ? and ?", max_age, min_age)
    }

    def self.with_valid_phone_number
      where("#{table_name}.formatted_phone is not null")
    end
  end

  def phone=(ph)
    super.tap do
      self.formatted_phone = PhoneNumber.new(ph.to_s).e164
    end
  end

  private

  def truncate_error_message
    error_message.truncate(512) if error_message
  end
end
