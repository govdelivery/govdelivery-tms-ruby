class SmsRecipient < ActiveRecord::Base
  include PhoneRecipient

  scope :to_send, lambda { |vendor_id, account_id = nil|
    incomplete.not_blacklisted(vendor_id, account_id).with_valid_phone_number
  }

  scope :not_sent, -> {where(sent_at: nil)}

  scope :blacklisted, lambda { |vendor_id, account_id|
    sql = <<-SQL
      inner join #{StopRequest.table_name}
              on (#{StopRequest.table_name}.vendor_id = ?
                   #{account_id ? "and NVL(#{StopRequest.table_name}.account_id, ?) = ?" : "and #{StopRequest.table_name}.account_id IS NULL" }
                 )
             and #{StopRequest.table_name}.phone = #{table_name}.formatted_phone
    SQL
    sql_array = [sql, vendor_id]
    sql_array.concat([account_id, account_id]) if account_id
    joins(sanitize_sql_array(sql_array))
      .readonly(false)
  }

  scope :not_blacklisted, lambda { |vendor_id, account_id|
    sql = <<-SQL
      left outer join #{StopRequest.table_name}
                   on (#{StopRequest.table_name}.vendor_id = ?
                        #{account_id ? "and NVL(#{StopRequest.table_name}.account_id, ?) = ?" : "and #{StopRequest.table_name}.account_id IS NULL" }
                      )
                  and #{StopRequest.table_name}.phone = #{table_name}.formatted_phone
    SQL
    sql_array = [sql, vendor_id]
    sql_array.concat([account_id, account_id]) if account_id
    joins(sanitize_sql_array(sql_array))
      .where("#{StopRequest.table_name}.phone is null")
      .readonly(false)
  }
end
