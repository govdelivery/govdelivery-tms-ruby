class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.references :account, :null => :false
      t.string :email, :null => :false
      t.string :password, :null => :false
      t.timestamps
    end

    add_index(:users, :email, :unique => true)    
  end
end