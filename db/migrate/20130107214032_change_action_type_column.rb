class ChangeActionTypeColumn < ActiveRecord::Migration
  def up
    change_column :actions, :action_type, :string, :null => false
    Action.reset_column_information
    {1 => 'dcm_unsubscribe', 2 => 'dcm_subscribe', 3 => 'forward'}.each do |int,string|
      puts int, string
      puts Action.update_all({:action_type => string}, {:action_type => int})
    end
  end

  def down
  end
end
