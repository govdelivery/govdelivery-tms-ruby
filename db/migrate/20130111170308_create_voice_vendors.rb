class CreateVoiceVendors < ActiveRecord::Migration
  def change
    add_column :accounts, :voice_vendor_id, :integer
    create_table :voice_vendors do |t|
      t.string "name", :null => false
      t.string "username", :null => false
      t.string "password", :null => false
      t.string "from_phone", :null => false
      t.string "worker", :null => false
      t.timestamps
    end
  end
end
