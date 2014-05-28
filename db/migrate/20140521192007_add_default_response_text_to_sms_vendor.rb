class AddDefaultResponseTextToSmsVendor < ActiveRecord::Migration
  def change
    add_column :sms_vendors, :default_response_text, :string
  end
end
