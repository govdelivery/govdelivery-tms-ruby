class CreateSmsPrefixes < ActiveRecord::Migration
  def change
    create_table :sms_prefixes do |t|
      t.string :prefix, null: false
      t.references :account, null: false
      t.references :sms_vendor, null: false
      t.timestamps
    end
  end
end
