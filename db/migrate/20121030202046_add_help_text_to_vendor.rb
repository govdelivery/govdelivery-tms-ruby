if !defined?(Vendor)
  class Vendor < ActiveRecord::Base
    DEFAULT_HELP_TEXT = "Go to http://bit.ly/govdhelp for help"
    DEFAULT_STOP_TEXT = "You will no longer receive SMS messages."
    RESERVED_KEYWORDS = %w(stop quit help)
  end
end

class AddHelpTextToVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :help_text, :string, :default => Vendor::DEFAULT_HELP_TEXT
    Vendor.reset_column_information
    Vendor.update_all(:help_text => Vendor::DEFAULT_HELP_TEXT)
    change_column :vendors, :help_text, :string, :default => Vendor::DEFAULT_HELP_TEXT, :null => false
  end
end
