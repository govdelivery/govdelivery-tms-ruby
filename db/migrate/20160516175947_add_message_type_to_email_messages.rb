class AddMessageTypeToEmailMessages < ActiveRecord::Migration
  def change
    add_reference :email_messages, :message_type, index: true
  end
end
