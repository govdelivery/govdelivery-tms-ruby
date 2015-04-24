class DropSharedFromSmsVendors < ActiveRecord::Migration
  def change
    remove_column :sms_vendors, :shared
  end
end
