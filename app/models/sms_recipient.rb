class SmsRecipient < ActiveRecord::Base
  include PhoneRecipient

  scope :to_send, ->(vendor_id, account_id=nil) { 
    if account_id.nil?
      incomplete.not_blacklisted(vendor_id).with_valid_phone_number 
    else
      incomplete.not_account_blacklisted(vendor_id, account_id).with_valid_phone_number 
    end
  }

  scope :not_sent, where(:sent_at => nil)
  scope :blacklisted, lambda { |vendor_id|
    sql = <<-SQL
      inner join #{StopRequest.table_name} 
              on #{StopRequest.table_name}.vendor_id = #{vendor_id} 
             and #{StopRequest.table_name}.phone = #{self.table_name}.formatted_phone
    SQL
    joins(sql).readonly(false)
  }

  scope :account_blacklisted, lambda { |vendor_id, account_id|
    sql = <<-SQL
      inner join #{StopRequest.table_name} 
              on (#{StopRequest.table_name}.vendor_id = #{vendor_id} 
                   and NVL(#{StopRequest.table_name}.account_id, #{account_id}) = #{account_id})
             and #{StopRequest.table_name}.phone = #{self.table_name}.formatted_phone
    SQL
    joins(sql).readonly(false)
  }

  scope :not_blacklisted, lambda { |vendor_id|
    sql = <<-SQL
      left outer join #{StopRequest.table_name} 
                   on #{StopRequest.table_name}.vendor_id = #{vendor_id} 
                  and #{StopRequest.table_name}.phone = #{self.table_name}.formatted_phone
    SQL
    joins(sql).where("#{StopRequest.table_name}.phone is null").readonly(false)
  }

  scope :not_account_blacklisted, lambda { |vendor_id, account_id|
    sql = <<-SQL
      left outer join #{StopRequest.table_name} 
                   on (#{StopRequest.table_name}.vendor_id = #{vendor_id} 
                        and NVL(#{StopRequest.table_name}.account_id, #{account_id}) = #{account_id})
                  and #{StopRequest.table_name}.phone = #{self.table_name}.formatted_phone
    SQL
    joins(sql).where("#{StopRequest.table_name}.phone is null").readonly(false)
  }
end
