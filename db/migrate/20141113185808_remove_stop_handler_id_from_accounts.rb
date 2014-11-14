class RemoveStopHandlerIdFromAccounts < ActiveRecord::Migration
  def change
    remove_column :accounts, :stop_handler_id
  end
end
