class CreateStopRequests < ActiveRecord::Migration
  def change
    create_table :stop_requests do |t|
      t.references :vendor, :null => false
      t.string :phone, :null => :false
      t.string :country_code, :null => :false, :limit => 4
      t.timestamps
    end

    add_index(:stop_requests, [:vendor_id, :phone, :country_code])
  end
end
