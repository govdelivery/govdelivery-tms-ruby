class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.references :account, null: false
      t.references :keyword, null: false
      t.integer :action_type, null: false
      t.string :name, limit: 255
      t.string :params, limit: 4000
      t.timestamps
    end
  end
end
