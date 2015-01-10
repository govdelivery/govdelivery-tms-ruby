class CreateFromNumbers < ActiveRecord::Migration
  def change
    create_table :from_numbers do |t|
      t.references :account
      t.string :phone_number
      t.datetime :created_at
      t.boolean :is_default, :default => false
    end
  end
end
