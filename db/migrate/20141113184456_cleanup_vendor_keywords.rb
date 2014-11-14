class CleanupVendorKeywords < ActiveRecord::Migration
  def change
    ['stop', 'help'].each do |type|
      Keyword.where(name: "Keywords::Vendor#{type.upcase}").each do |k|
        SmsVendor.where(id: k.vendor_id).update_all("#{type}_text = #{k.response_text}")
      end
    end
    Keyword.where(name: ["Keywords::VendorHelp", "Keywords::VendorDefault", "Keywords::VendorStart", "Keywords::VendorStop"]).delete_all
  end
end
