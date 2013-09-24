class AddIsVoiceToVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :voice, :boolean, :default => false
  end
end
