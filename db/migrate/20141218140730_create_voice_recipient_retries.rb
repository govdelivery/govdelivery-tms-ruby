class CreateVoiceRecipientRetries < ActiveRecord::Migration
  def change
    create_table :voice_recipient_retries do |t|
      t.references :voice_message,   :null => false
      t.references :voice_recipient, :null => false
      t.datetime   :completed_at
      t.string     :status
      t.string     :secondary_status
    end
  end
end
