class RemoveHelpTextAndStopTextFromAccounts < ActiveRecord::Migration
  def change
    remove_column :accounts, :stop_text
    remove_column :accounts, :help_text
  end
end
