class MakeVendorUniqueByFrom < ActiveRecord::Migration
  def up
    add_index :sms_vendors, :from_phone, unique: true
  rescue
    say "Exception ignored: #{e}\nIndex will need to be added manually."
  end

  def down
    remove_index :sms_vendors, :from_phone
  rescue
    say "Exception ignored: #{e}"
  end
end
