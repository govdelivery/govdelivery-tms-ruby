class AddAccountToInboundMessages < ActiveRecord::Migration
  def change
    add_column :inbound_messages, :account_id, :integer
    add_index :inbound_messages, :account_id
  end
end
