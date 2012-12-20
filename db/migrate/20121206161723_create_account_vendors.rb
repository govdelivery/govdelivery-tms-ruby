class CreateAccountVendors < ActiveRecord::Migration
class AccountVendor < ActiveRecord::Base
  attr_accessible :account, :vendor
  belongs_to :account
  belongs_to :vendor
  
end
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
