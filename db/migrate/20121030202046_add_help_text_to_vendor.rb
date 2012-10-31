class AddHelpTextToVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :help_text, :string, :default => Vendor::DEFAULT_HELP_TEXT
    Vendor.reset_column_information
    Vendor.update_all(:help_text => Vendor::DEFAULT_HELP_TEXT)
    change_column :vendors, :help_text, :string, :default => Vendor::DEFAULT_HELP_TEXT, :null => false
  end
end
