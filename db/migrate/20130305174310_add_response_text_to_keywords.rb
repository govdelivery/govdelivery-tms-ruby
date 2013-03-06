class AddResponseTextToKeywords < ActiveRecord::Migration
  def change
    add_column :keywords, :response_text, :string, limit: 160
  end
end
