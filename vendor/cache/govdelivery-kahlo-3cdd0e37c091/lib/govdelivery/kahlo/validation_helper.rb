require 'global_phone'

GlobalPhone.db_path = File.join(File.dirname(__FILE__), "global_phone.json")

module GovDelivery
  module Kahlo
    module ValidationHelper

      ##
      # Returns true if Kahlo will recognize a phone number as valid.
      # This is a simple sanity check, not a guarantee that Kahlo
      # will be able to deliver.
      def valid_phone?(phone)
        GlobalPhone.validate(phone)
      end

      ##
      # Returns true if given a valid phone number or short code.
      def valid_phone_or_short_code?(number)
        /\A\d{5,6}\z/ === number || valid_phone?(number)
      end

      ##
      # Returns true if the number could be a Kahlo from number.
      # This doesn't guarantee validity, but can be used to prevent
      # obviously bad from numbers.
      def plausible_from_number?(number)
        valid_phone_or_short_code?(number) || number == 'loopback'
      end
    end
  end
end