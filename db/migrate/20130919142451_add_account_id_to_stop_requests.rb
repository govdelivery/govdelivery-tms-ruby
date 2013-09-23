class AddAccountIdToStopRequests < ActiveRecord::Migration
  def change
    add_column :stop_requests, :account_id, :integer, :default => nil
  end
end
