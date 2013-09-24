class AddHelpTextToVendor < ActiveRecord::Migration
  DEFAULT_HELP_TEXT = "Go to http://bit.ly/govdhelp for help"
  DEFAULT_STOP_TEXT = "You will no longer receive SMS messages."

  def change
    add_column :vendors, :help_text, :string, :default => DEFAULT_HELP_TEXT
    change_column :vendors, :help_text, :string, :default => DEFAULT_HELP_TEXT, :null => false
  end
end
