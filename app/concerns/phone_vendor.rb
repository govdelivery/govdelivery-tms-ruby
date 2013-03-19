module PhoneVendor
  extend ActiveSupport::Concern

  included do
    alias_attribute :from, :from_phone
    attr_accessible :from

    validates_presence_of :from

    validate :normalize_from_phone
  end

  def normalize_from_phone
    self.from_phone = PhoneNumber.new(from_phone).e164_or_short if from_phone
  end
end