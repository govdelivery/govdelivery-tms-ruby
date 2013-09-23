class AddStopAndHelpTextToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :help_text, :string
    add_column :accounts, :stop_text, :string
  end
end
