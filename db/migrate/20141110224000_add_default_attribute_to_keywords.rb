class AddDefaultAttributeToKeywords < ActiveRecord::Migration
  def change
    add_column :keywords, :is_default, :boolean
    execute <<SQL
UPDATE (SELECT keywords.is_default as is_default
FROM keywords
JOIN accounts
ON keywords.account_id = accounts.id
WHERE keywords.type = 'default') x
set x.is_default = 1
SQL
  end
end
