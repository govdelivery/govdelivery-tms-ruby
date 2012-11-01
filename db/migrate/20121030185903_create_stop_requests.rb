class CreateStopRequests < ActiveRecord::Migration
  def change
    create_table :stop_requests do |t|
      t.references :vendor, :null => false
      t.string :phone, :null => :false
      t.timestamps
    end

    add_index(:stop_requests, [:vendor_id, :phone])
  end
end
