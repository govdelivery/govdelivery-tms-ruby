class RemoveAccountIdAndEventHandlerIdFromCommands < ActiveRecord::Migration
  def change
    remove_column :commands, :account_id
    remove_column :commands, :event_handler_id
  end
end
