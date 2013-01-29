class AddEmailMessageAck < ActiveRecord::Migration
  def change
    add_column :email_messages, :ack, :string
  end
end
