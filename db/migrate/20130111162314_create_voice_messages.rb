class CreateVoiceMessages < ActiveRecord::Migration
  def change
    create_table :voice_messages do |t|
      t.string :play_url, limit: 512
      t.datetime :created_at
      t.time :completed_at
      t.references :user
      t.references :account
    end
  end
end
