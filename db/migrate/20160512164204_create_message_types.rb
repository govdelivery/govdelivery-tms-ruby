class CreateMessageTypes < ActiveRecord::Migration
  def change
    create_table :message_types do |t|
      t.references :account, null: false
      t.string :name, null: false, limit: 255
      t.string :name_key, null: false, limit: 255
    end
  end
end
