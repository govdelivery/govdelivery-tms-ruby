class AddStopTextToVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :stop_text, :string, :default => Vendor::DEFAULT_STOP_TEXT
    Vendor.reset_column_information
    Vendor.update_all(:help_text => Vendor::DEFAULT_STOP_TEXT)
    change_column :vendors, :stop_text, :string, :null => false, :default => Vendor::DEFAULT_STOP_TEXT
  end
end
