class CreateSmsVendors < ActiveRecord::Migration
  def change
    add_column :accounts, :sms_vendor_id, :integer
    remove_column :vendors, :vtype
    remove_column :vendors, :voice
    rename_column :vendors, :from, :from_phone
    rename_table :vendors, :sms_vendors
    drop_table :account_vendors
  end
end
