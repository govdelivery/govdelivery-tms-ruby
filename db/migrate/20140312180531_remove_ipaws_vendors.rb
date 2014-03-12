class RemoveIPAWSVendors < ActiveRecord::Migration
  def up
    drop_table :ipaws_vendors
    remove_column :accounts, :ipaws_vendor_id
    add_column :accounts, :ipaws_enabled, :boolean, null: false, default: false
  end

  def down
  end
end
