class MakeKeywordsNameIndexCaseInsensitive < ActiveRecord::Migration
  def up
    remove_index :keywords, [:vendor_id, :account_id, :name]
    add_index :keywords, [:vendor_id, :account_id, 'LOWER("NAME")'], :unique => true
  end

  def down
    remove_index :keywords, [:vendor_id, :account_id, 'LOWER("NAME")'], :unique => true
    add_index :keywords, [:vendor_id, :account_id, :name], :unique => true
  end
end
