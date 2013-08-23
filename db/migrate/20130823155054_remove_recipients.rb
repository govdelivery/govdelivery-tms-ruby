class RemoveRecipients < ActiveRecord::Migration
  def up
    drop_table :recipients
  end

  def down
    raise 'nope'
  end
end
