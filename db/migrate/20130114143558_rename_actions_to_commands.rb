ActionParameters = CommandParameters # a little trick for reserializing params
class RenameActionsToCommands < ActiveRecord::Migration
  def up
    # you would never do this in a "no downtime" release, but seeing as there is no 
    # production server yet, this is ok
    rename_table :actions, :commands
    rename_column :commands, :action_type, :command_type
    Command.all.each do |c|
      c.save!
    end
  end

  def down
    rename_table :commands, :actions
    rename_column :actions, :command_type, :action_type
  end
end
