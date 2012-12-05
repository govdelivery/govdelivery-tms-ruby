class ChangeIndexOnKeywordFromAccountToVendor < ActiveRecord::Migration
  def up
    remove_index :keywords, [:account_id, :name]
    add_index :keywords, [:vendor_id, :name], :unique => true
  end

  def down
    add_index :keywords, [:account_id, :name], :unique => true
    remove_index :keywords, [:vendor_id, :name]
  end
end
