class AddReplyAndErrorsToEmailMessages < ActiveRecord::Migration
  def change
    add_column :email_messages, :reply_to, :string, :size => 255
    add_column :email_messages, :errors_to, :string, :size => 255
  end
end
