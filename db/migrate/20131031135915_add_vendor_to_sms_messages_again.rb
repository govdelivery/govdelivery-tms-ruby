class AddVendorToSmsMessagesAgain < ActiveRecord::Migration
  def change
    # add sms_vendor_id to all sms_messages
    SmsMessage.connection.execute <<-SQL
      UPDATE sms_messages
      SET sms_messages.sms_vendor_id=
        (SELECT accounts.sms_vendor_id
        FROM accounts
        WHERE sms_messages.account_id = accounts.id)
    SQL

    # make it not null
    change_column :sms_messages, :sms_vendor_id, :integer, :null => false
  end
end
