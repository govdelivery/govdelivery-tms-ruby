class CreateMessageTypes < ActiveRecord::Migration
  def change
    create_table :message_types do |t|
      t.references :account, null: false
      t.string :label, null: false, limit: 255
      t.string :code, null: false, limit: 255
    end
  end
end
