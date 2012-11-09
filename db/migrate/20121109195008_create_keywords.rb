class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.references :account
      t.boolean :stop, :default => 0
      t.string :name, :null => false, :limit => 160
      t.timestamps
    end
    add_index :keywords, [:account_id, :name], :unique => true
    Account.reset_column_information
    Account.all.each do |a|
      a.create_stop_keyword!(:name => "STOP")
    end
  end
end
