class AddErrorMessageToCommandStatus < ActiveRecord::Migration
  def change
    add_column :command_actions, :error_message, :string
  end
end
