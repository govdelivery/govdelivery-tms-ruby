class CreateOneTimeSessionToken < ActiveRecord::Migration
  def change
    create_table :one_time_session_tokens do |t|
      t.string :value, null: false
      t.references :user
      t.timestamps
    end
    add_index :one_time_session_tokens, :value, unique: true
  end
end
