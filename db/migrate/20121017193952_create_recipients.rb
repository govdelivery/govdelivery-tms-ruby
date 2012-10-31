class CreateRecipients < ActiveRecord::Migration
  def change
    create_table :recipients do |t|
      t.references :message,     :null => :false
      t.string  :phone,          :null => :false
      t.string  :country_code,   :null => :false, :default => 1
      t.string  :provided_phone, :null => :false
      t.string  :provided_country_code, :null => :false
      t.string  :ack
      t.integer :status,         :null => :false, :default => 1
      t.string  :error_message, :limit => 512
      t.time  :sent_at
      t.time  :completed_at
      t.timestamps
    end

    add_index(:recipients, :message_id)
  end
end
