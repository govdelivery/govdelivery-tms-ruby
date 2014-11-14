class FixResponseText < ActiveRecord::Migration
  def up
    begin
      Keywords::AccountDefault.delete_all # start over
    rescue
    end

    Account.all.select{ |a| a.sms_vendor.present? }.each do |account|
      rt = account.read_attribute(:help_text) || Keywords::DEFAULT_HELP_TEXT
      account.create_default_keyword!(response_text: rt) if account.default_keyword.nil?

      st = account.read_attribute(:stop_text) || Keywords::DEFAULT_STOP_TEXT
      account.stop_keyword.update_attribute(:response_text, st)

      ht = account.read_attribute(:help_text) || Keywords::DEFAULT_HELP_TEXT
      account.help_keyword.update_attribute(:response_text, ht)
    end

    begin
      Keywords::VendorDefault.delete_all # start over
    rescue
    end

    SmsVendor.all.each do |sms_vendor|
      rt = sms_vendor.read_attribute(:help_text) || Keywords::DEFAULT_HELP_TEXT
      sms_vendor.create_default_keyword!(response_text: rt) if sms_vendor.default_keyword.nil?

      st = sms_vendor.read_attribute(:stop_text) || Keywords::DEFAULT_STOP_TEXT
      sms_vendor.stop_keyword.update_attribute(:response_text, st)

      ht = sms_vendor.read_attribute(:help_text) || Keywords::DEFAULT_HELP_TEXT
      sms_vendor.help_keyword.update_attribute(:response_text, ht)
    end
  end

  def down
  end
end
