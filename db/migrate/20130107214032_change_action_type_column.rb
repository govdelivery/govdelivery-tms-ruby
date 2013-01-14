Action = Command # Action might not exist anymore... 
class ChangeActionTypeColumn < ActiveRecord::Migration
  def up
    rename_column :actions, :action_type, :action_type_old
    add_column :actions, :action_type, :string#, :null => false
    Action.connection.execute "UPDATE actions SET action_type=action_type_old"
    change_column :actions, :action_type, :string, :null => false
    remove_column :actions, :action_type_old
    
    # Action.reset_column_information
    # {1 => 'dcm_unsubscribe', 2 => 'dcm_subscribe', 3 => 'forward'}.each do |int,string|
    #   puts int, string
    #   puts Action.update_all({:action_type => string}, {:action_type => int})
    # end
  end

  def down
  end
end
