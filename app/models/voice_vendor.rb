class VoiceVendor < ActiveRecord::Base
  include Vendor
  include PhoneVendor

  def delivery_mechanism
    Service::TwilioClient::Voice.new(username, password)
  end
end
