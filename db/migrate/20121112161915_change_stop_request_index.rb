class ChangeStopRequestIndex < ActiveRecord::Migration
  def up
    # remove the existing index
    remove_index(:stop_requests, [:vendor_id, :phone])
    # de-dupify the table by destroying the data (heavy-handed, i know, but we have no production data yet)
    StopRequest.delete_all                             
    # 
    add_index(:stop_requests, [:vendor_id, :phone], :unique => true)
  end
  
  def down
    remove_index(:stop_requests, [:vendor_id, :phone])
    add_index(:stop_requests, [:vendor_id, :phone])
  end
end
