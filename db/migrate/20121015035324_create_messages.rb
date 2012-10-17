class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :short_body
      t.string :recipients
      t.string :ack
      t.time :completed
      t.timestamps
    end
  end
end
