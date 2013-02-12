class CreateEmailRecipientOpens < ActiveRecord::Migration
  def change
    create_table :email_recipient_opens do |t|
      t.references :email_message, null: false
      t.references :email_recipient, null: false
      t.string :event_ip, null: false
      t.string :email, limit: 256, null: false
      t.time :opened_at, null: false

      t.time :created_at, null: false
    end
  end
end
