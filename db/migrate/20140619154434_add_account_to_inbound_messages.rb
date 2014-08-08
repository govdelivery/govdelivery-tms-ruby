class AddAccountToInboundMessages < ActiveRecord::Migration
  def change
    add_column :inbound_messages, :account_id, :integer
    add_index :inbound_messages, :account_id
    # set inbound_message.account_id from inbound_message.keyword.account_id
    execute <<SQL
update (SELECT keywords.id as keyword_id,
  inbound_messages.id as inbound_message_id,
  inbound_messages.account_id as inbound_message_account_id,
  keywords.account_id as keyword_account_id
FROM inbound_messages
JOIN keywords
ON inbound_messages.keyword_id = keywords.id
WHERE inbound_messages.account_id IS NULL and keywords.account_id is not null) x
set x.inbound_message_account_id = x.keyword_account_id
SQL
  end
end
