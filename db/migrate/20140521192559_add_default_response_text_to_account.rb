class AddDefaultResponseTextToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :default_response_text, :string
  end
end
