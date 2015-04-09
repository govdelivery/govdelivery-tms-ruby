class AddSharedToSmsVendor < ActiveRecord::Migration
  def change
    add_column :sms_vendors, :shared, :boolean, default: false
    SmsVendor.reset_column_information
    SmsVendor.update_all(shared: false)
    change_column :sms_vendors, :shared, :boolean, default: false, null: false
  end
end
