class AddIndexToClicks < ActiveRecord::Migration
  def change
    add_index :email_recipient_clicks, [:email_message_id, :email_recipient_id]
    add_index :email_recipient_opens, [:email_message_id, :email_recipient_id]
  end
end
