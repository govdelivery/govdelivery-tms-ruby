class RemoveVendorDeliveryTimeouts < ActiveRecord::Migration
  def change
    remove_column :email_vendors, :delivery_timeout
    remove_column :sms_vendors, :delivery_timeout
    remove_column :voice_vendors, :delivery_timeout
  end
end
