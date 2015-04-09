class AddVendorPhoneToInboundMessages < ActiveRecord::Migration
  def change
    rename_column :inbound_messages, :from_phone, :caller_phone
    add_column :inbound_messages, :vendor_phone, :string, limit: 100
  end
end
