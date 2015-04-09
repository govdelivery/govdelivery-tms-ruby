class RemoveFromPhoneFromVoiceVendor < ActiveRecord::Migration
  def up
    ::VoiceVendor.all.each do |voice_vendor|
      from_number = voice_vendor.from_phone
      voice_vendor.accounts.each do |account|
        account.from_numbers.build(phone_number: from_number, is_default: true)
        account.save!
      end
    end

    remove_column :voice_vendors, :from_phone
  end

  def down
    add_column :voice_vendors, :from_phone, :string
  end
end
