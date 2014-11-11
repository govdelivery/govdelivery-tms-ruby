class RemoveVendorKeywords < ActiveRecord::Migration
  def change
    execute <<SQL
delete FROM keywords
WHERE vendor_id IS NOT NULL and account_id IS NULL
SQL
  end
end
