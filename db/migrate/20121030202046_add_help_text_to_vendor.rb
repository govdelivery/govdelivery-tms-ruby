class AddHelpTextToVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :help_text, :string, :default => "Go to http://bit.ly/govdhelp for help"
  end
end
