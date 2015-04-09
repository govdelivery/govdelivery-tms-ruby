class CreateEmailRecipientClicks < ActiveRecord::Migration
  def change
    create_table :email_recipient_clicks do |t|
      t.references :email_message,   null: false
      t.references :email_recipient, null: false
      t.string :email,               null: false, limit: 256
      t.string :url,                 null: false, limit: 4000
      t.datetime :clicked_at,        null: false
      t.datetime :created_at,        null: false
    end
  end
end
