class AddSidToInboundMessages < ActiveRecord::Migration
  def change
    add_column :inbound_messages, :vendor_sid, :string
    add_index :inbound_messages, :vendor_sid, unique: true
  end
end
