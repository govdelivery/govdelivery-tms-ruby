class VoiceVendor < ActiveRecord::Base
  include Vendor
  include PhoneVendor
end
