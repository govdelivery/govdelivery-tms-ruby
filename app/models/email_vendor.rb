class EmailVendor < ActiveRecord::Base
  include Vendor

  def username
    Rails.configuration.odm_username
  end

  def password
    Rails.configuration.odm_password
  end
end
