class AddSessionsTable < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string :data,       limit: 4000
      t.string :session_id, null: false, limit: 255
      t.timestamps
    end

    add_index :sessions, :session_id, :unique => true
  end
end
