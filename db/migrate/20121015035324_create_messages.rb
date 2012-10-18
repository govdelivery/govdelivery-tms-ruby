class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :short_body, :null => :false
      t.time :completed
      t.timestamps
    end
  end
end
