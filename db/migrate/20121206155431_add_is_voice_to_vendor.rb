class AddIsVoiceToVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :voice, :boolean, :default => false
    Vendor.reset_column_information
  end
end
