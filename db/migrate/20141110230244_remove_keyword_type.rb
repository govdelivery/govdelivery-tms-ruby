class RemoveKeywordType < ActiveRecord::Migration
  def change
    remove_column :keywords, :type
  end
end
