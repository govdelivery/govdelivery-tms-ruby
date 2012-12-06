class CreateAccountVendors < ActiveRecord::Migration
  def change
    create_table :account_vendors do |t|
      t.references :account
      t.references :vendor
      t.timestamps
    end

    Account.all.each do |account|
      AccountVendor.create!(:account_id=>account.id, :vendor_id=> account.vendor_id)
    end

    remove_column :accounts, :vendor_id
  end
end
