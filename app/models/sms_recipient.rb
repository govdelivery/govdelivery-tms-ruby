class SmsRecipient < ActiveRecord::Base
  include PhoneRecipient

  scope :to_send, -> vendor_id { incomplete.not_blacklisted(vendor_id).with_valid_phone_number }

  scope :incomplete, where(:sent_at => nil)
  scope :blacklisted, lambda { |vendor_id|
    joins("inner join #{StopRequest.table_name} on #{StopRequest.table_name}.vendor_id = #{vendor_id} and #{StopRequest.table_name}.phone = #{self.table_name}.formatted_phone").readonly(false)
  }

  scope :not_blacklisted, lambda { |vendor_id|
    joins("left outer join #{StopRequest.table_name} on #{StopRequest.table_name}.vendor_id = #{vendor_id} and #{StopRequest.table_name}.phone =  #{self.table_name}.formatted_phone").where("#{StopRequest.table_name}.phone is null").readonly(false)
  }


end
