class CreateEmailVendors < ActiveRecord::Migration
  def change
    add_column :accounts, :email_vendor_id, :integer
    create_table :email_vendors do |t|
      t.string 'name', null: false
      t.string 'username', null: false
      t.string 'password', null: false
      t.string 'worker', null: false
      t.timestamps
    end
  end
end
