class RemoveFromPhoneFromVoiceVendor < ActiveRecord::Migration
  def change
    remove_column :voice_vendors, :from_phone
  end
end
