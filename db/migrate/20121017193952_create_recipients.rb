class CreateRecipients < ActiveRecord::Migration
  def change
    create_table :recipients do |t|
      t.references :message,     null: false
      t.references :vendor,      null: false
      t.string :phone
      t.string :formatted_phone
      t.string :ack
      t.integer :status,         null: false, default: 1
      t.string :error_message, limit: 512
      t.time :sent_at
      t.time :completed_at
      t.timestamps
    end

    add_index(:recipients, :message_id)
  end
end
