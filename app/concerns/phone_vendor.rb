module PhoneVendor
  extend ActiveSupport::Concern

  included do
    #moved out from_number (from) because Voice does not use it. I am concerned about this concern now
  end
end