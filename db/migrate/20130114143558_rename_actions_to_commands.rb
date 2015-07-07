ActionParameters = CommandParameters # a little trick for reserializing params
class RenameActionsToCommands < ActiveRecord::Migration
  def up
    # you would never do this in a "no downtime" release, but seeing as there is no
    # production server yet, this is ok
    execute('alter table actions rename to commands')
    rename_column :commands, :action_type, :command_type
    Command.reset_column_information
    Command.all.each(&:save!)
  end

  def down
    execute('alter table commands rename to actions')
    rename_column :actions, :command_type, :action_type
  end
end
