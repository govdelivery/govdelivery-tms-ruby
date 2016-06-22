class AddFromNameToFromAddress < ActiveRecord::Migration
  def change
    add_column :from_addresses, :from_name, :string
  end
end