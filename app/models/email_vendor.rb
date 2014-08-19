class EmailVendor < ActiveRecord::Base
  include Vendor
  attr_accessible :deliveries_sequence, :clicks_sequence, :opens_sequence

  scope :tms_extended, -> { where(worker: Odm::TMS_EXTENDED_WORKER) }

  def username
    Rails.configuration.odm_username
  end

  def password
    Rails.configuration.odm_password
  end
end
