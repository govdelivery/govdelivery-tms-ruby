class AddVendorRelationshipToKeyword < ActiveRecord::Migration
  def change
    add_column :keywords, :vendor_id, :integer
  end
end
