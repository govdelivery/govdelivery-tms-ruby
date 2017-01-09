class AddMessageTypeToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :sms_message_type, :string, length: 20
  end
end
