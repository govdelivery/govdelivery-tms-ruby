class AddStatsTimeoutToVendors < ActiveRecord::Migration
  def change
    add_column :email_vendors, :delivery_timeout, :integer
    add_column :sms_vendors, :delivery_timeout, :integer
    add_column :voice_vendors, :delivery_timeout, :integer
  end
end
