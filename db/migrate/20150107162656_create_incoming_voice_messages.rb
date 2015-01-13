class CreateIncomingVoiceMessages < ActiveRecord::Migration
  def change
    create_table :incoming_voice_messages do |t|
      t.references :from_number
      t.string :play_url, :limit => 512
      t.string :say_text, :limit => 1000
      t.boolean :is_default, :default => false, :null => false
      t.integer :expires_in
      t.datetime :created_at
    end
  end
end
