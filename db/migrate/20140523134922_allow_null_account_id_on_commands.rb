class AllowNullAccountIdOnCommands < ActiveRecord::Migration
  def up
    change_column :commands, :account_id, :integer, null: true
  end

  def down
    change_column :commands, :account_id, :integer, null: false
  end
end
