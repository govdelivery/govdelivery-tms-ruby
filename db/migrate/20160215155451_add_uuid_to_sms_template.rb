class AddUuidToSmsTemplate < ActiveRecord::Migration
  def change
    add_column :sms_templates, :uuid, :string
    SmsTemplate.update_all("uuid = id")
    add_index :sms_templates, [:account_id, :uuid], :unique => true
  end
end
