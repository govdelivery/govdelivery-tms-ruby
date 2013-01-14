module PhoneVendor
  extend ActiveSupport::Concern

  included do
    alias_attribute :from, :from_phone
    attr_accessible :from

    validates_presence_of :from
  end
end