class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.references :account, :null => :false
      t.string :username, :null => :false
      t.timestamps
    end
  end
end