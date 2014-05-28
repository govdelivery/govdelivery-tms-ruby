class AddKeywordRefToCommands < ActiveRecord::Migration
  def change
    add_column :commands, :keyword_id, :integer
    add_index  :commands, :keyword_id
  end
end
