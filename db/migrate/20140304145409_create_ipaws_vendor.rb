class CreateIPAWSVendor < ActiveRecord::Migration
  def change
    create_table :ipaws_vendors do |t|
      t.timestamps
    end
    add_column :accounts, :ipaws_vendor_id, :integer
  end
end
