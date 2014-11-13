class RemoveVendorIdEventHandlerIdAndTypeFromKeyword < ActiveRecord::Migration
  def change
    remove_column :keywords, :vendor_id
    remove_column :keywords, :event_handler_id
    remove_column :keywords, :type
  end
end
