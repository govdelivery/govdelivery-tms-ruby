class AddIndexToRecipientsTables < ActiveRecord::Migration
  def change
    add_index :email_recipients, [:message_id, :id]
    add_index :sms_recipients, [:message_id, :id]
    add_index :voice_recipients, [:message_id, :id]
  end
end
