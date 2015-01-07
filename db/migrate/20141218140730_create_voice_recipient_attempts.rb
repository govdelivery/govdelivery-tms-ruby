class CreateVoiceRecipientAttempts < ActiveRecord::Migration
  def change
    create_table :voice_recipient_attempts do |t|
      t.references :voice_message, null: false
      t.references :voice_recipient, null: false
      t.datetime :completed_at
      t.string :ack
      t.string :description, limit: 50
    end
  end
end
