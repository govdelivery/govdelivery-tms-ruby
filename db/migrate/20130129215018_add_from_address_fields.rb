class AddFromAddressFields < ActiveRecord::Migration
  def change
    drop_table :from_addresses rescue nil
    create_table :from_addresses do |t|
      t.references :account
      t.string :from_email
      t.string :reply_to_email
      t.string :bounce_email
      t.datetime :created_at
    end
  end
end
