class RemoveAccountIdFromCommands < ActiveRecord::Migration
  def change
    remove_column :commands, :account_id
  end
end
