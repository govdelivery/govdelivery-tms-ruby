class DropEventHandlers < ActiveRecord::Migration
  def change
    drop_table :event_handlers
  end
end
