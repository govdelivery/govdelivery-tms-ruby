class AddCreatedAtToRecipients < ActiveRecord::Migration
  def change
    add_column :sms_recipients, :created_at, :datetime
    add_column :voice_recipients, :created_at, :datetime
  end
end
