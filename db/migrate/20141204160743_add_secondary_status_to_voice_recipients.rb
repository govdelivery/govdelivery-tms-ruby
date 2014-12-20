class AddSecondaryStatusToVoiceRecipients < ActiveRecord::Migration
  def change
    add_column :voice_recipients, :secondary_status, :string
  end
end
