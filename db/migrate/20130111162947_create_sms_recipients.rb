class CreateSmsRecipients < ActiveRecord::Migration
  def change
    create_table :sms_recipients do |t|
      t.references :message, null: false
      t.references :vendor
      t.string :phone
      t.string :formatted_phone
      t.string :ack
      t.integer :status, null: false, default: 1
      t.string :error_message, limit: 512
      t.time :sent_at
      t.time :completed_at
    end
  end
end
