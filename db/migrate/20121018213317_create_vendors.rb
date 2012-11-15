class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string :name, :null => false
      t.string :username, :null => false
      t.string :password, :null => false
      t.string :from, :null => false
      t.string :worker, :null => false 
      t.timestamps
    end
  end
end
