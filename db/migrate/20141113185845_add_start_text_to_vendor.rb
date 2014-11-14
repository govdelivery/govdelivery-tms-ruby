class AddStartTextToVendor < ActiveRecord::Migration
  def change
    add_column :sms_vendors, :start_text, :string
  end
end
