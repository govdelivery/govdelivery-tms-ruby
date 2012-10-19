class CreateRecipients < ActiveRecord::Migration
  def change
    create_table :recipients do |t|
      t.references :message, :null => :false
      t.string  :phone, :null => :false
      t.string  :country_code, :null => :false
      t.string  :ack
      t.string  :status
      t.string  :error_message, :limit => 512
      t.time  :sent_at
      t.time  :completed_at
      t.timestamps
    end
  end
end
