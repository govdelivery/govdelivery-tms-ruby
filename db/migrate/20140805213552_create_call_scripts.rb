class CreateCallScripts < ActiveRecord::Migration
  def change
    create_table :call_scripts do |t|
      t.references :voice_message
      t.string :say_text, limit: 1000
      t.timestamps
    end
    add_column :voice_messages, :say_text, :string, limit: 1000
  end
end
