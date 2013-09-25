class ChangeStopRequestIndexAgain < ActiveRecord::Migration
  def up
    remove_index(:stop_requests, [:vendor_id, :phone])
    add_index(:stop_requests, [:vendor_id, :account_id, :phone], :unique => true)
  end

  def down
    remove_index(:stop_requests, [:vendor_id, :account_id, :phone])
    add_index(:stop_requests, [:vendor_id, :phone], :unique => true)
  end
end
