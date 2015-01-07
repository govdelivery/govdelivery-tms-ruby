class AddRetryParametersToVoiceMessage < ActiveRecord::Migration
  def change
    add_column :voice_messages, :max_retries, :integer, null: false, default: 0
    add_column :voice_messages, :retry_delay, :integer, null: false, default: 300
  end
end
