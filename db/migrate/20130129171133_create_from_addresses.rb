class CreateFromAddresses < ActiveRecord::Migration
  def change
    create_table :from_addresses do |t|
      t.references :account
      t.string :email
      t.datetime :created_at
    end
  end
end
