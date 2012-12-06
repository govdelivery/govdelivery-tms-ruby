class AddUrlToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :url, :string
    change_column :messages, :short_body, :string, :null=>true
  end
end
