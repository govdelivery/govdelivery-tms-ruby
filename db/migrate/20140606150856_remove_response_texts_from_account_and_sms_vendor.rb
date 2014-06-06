class RemoveResponseTextsFromAccountAndSmsVendor < ActiveRecord::Migration
  def up
    remove_column :accounts, :help_text
    remove_column :accounts, :stop_text
    remove_column :accounts, :default_response_text
    remove_column :sms_vendors, :help_text
    remove_column :sms_vendors, :stop_text
    remove_column :sms_vendors, :default_response_text
  end

  def down
    add_column :accounts, :help_text
    add_column :accounts, :stop_text
    add_column :accounts, :default_response_text
    add_column :sms_vendors, :help_text
    add_column :sms_vendors, :stop_text
    add_column :sms_vendors, :default_response_text
  end
end
