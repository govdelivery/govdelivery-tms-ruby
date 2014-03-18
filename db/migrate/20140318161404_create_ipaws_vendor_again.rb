class CreateIPAWSVendorAgain < ActiveRecord::Migration
  def up
    create_table :ipaws_vendors do |t|
      t.integer :cog_id, null: false
      t.string  :user_id, null: false
      t.text    :public_password_encrypted, null: false
      t.text    :private_password_encrypted, null: false
      t.binary  :jks, null: false
      t.timestamps
    end
    add_column :accounts, :ipaws_vendor_id, :integer
    remove_column :accounts, :ipaws_enabled
  end

  def down
    drop_table :ipaws_vendors
    remove_column :accounts, :ipaws_vendor_id
    add_column :accounts, :ipaws_enabled, :boolean, null: false, default: false
  end
end
