class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :user, :null => :false
      t.string :short_body, :null => :false
      t.time :completed_at
      t.timestamps
    end
  end
end
