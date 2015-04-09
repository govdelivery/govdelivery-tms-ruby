class AddStopTextToVendor < ActiveRecord::Migration
  DEFAULT_HELP_TEXT = 'Go to http://bit.ly/govdhelp for help'
  DEFAULT_STOP_TEXT = 'You will no longer receive SMS messages.'
  RESERVED_KEYWORDS = %w(stop quit help)

  def change
    add_column :vendors, :stop_text, :string, default: DEFAULT_STOP_TEXT
    change_column :vendors, :stop_text, :string, null: false, default: DEFAULT_STOP_TEXT
  end
end
