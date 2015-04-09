class MakeAccountIdNotNullSmsMessages < ActiveRecord::Migration
  def change
    # These already have a validates_presence_of on them - just adding
    # the database portion
    change_column(:sms_messages,   :account_id, :integer, null: false)
    change_column(:voice_messages, :account_id, :integer, null: false)
    change_column(:email_messages, :account_id, :integer, null: false)
    change_column(:sms_recipients, :phone,      :string,  null: false)
    change_column(:sms_recipients, :vendor_id,  :integer, null: false)
  end
end
