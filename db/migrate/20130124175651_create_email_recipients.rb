class CreateEmailRecipients < ActiveRecord::Migration
  def change
    create_table :email_recipients do |t|
      t.references :message, null: false
      t.references :vendor
      t.string :ack, limit: 255
      t.string :email, limit: 255
      t.string :status, null: false, default: 'new'
      t.string :error_message, limit: 512
      t.time :sent_at
      t.time :completed_at
      t.timestamps
    end
  end
end
