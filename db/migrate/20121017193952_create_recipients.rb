class CreateRecipients < ActiveRecord::Migration
  def change
    create_table :recipients do |t|
      t.references :message, :null => :false
      t.string  :phone, :null => :false
      t.string :ack
      t.time :completed
      t.timestamps
    end
  end
end
