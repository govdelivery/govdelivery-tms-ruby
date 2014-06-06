class DataMigrationMoveResponseTextToKeywords < ActiveRecord::Migration
  # conditionals for future proofing
  def up
    Account.all.each do |account|
      account.stop_keyword.update_attribute :response_text, account.read_attribute(:stop_text) if account.respond_to?(:stop_keyword) && account.stop_keyword.present?
      account.help_keyword.update_attribute :response_text, account.read_attribute(:help_text) if account.respond_to?(:help_keyword) && account.help_keyword.present?
      account.default_keyword.update_attribute :response_text, account.read_attribute(:help_text) if account.respond_to?(:default_keyword) && account.default_keyword.present?
    end
    SmsVendor.all.each do |sms_vendor|
      sms_vendor.stop_keyword.update_attribute :response_text, sms_vendor.read_attribute(:stop_text) if sms_vendor.respond_to?(:stop_keyword) && sms_vendor.stop_keyword.present?
      sms_vendor.help_keyword.update_attribute :response_text, sms_vendor.read_attribute(:help_text) if sms_vendor.respond_to?(:help_keyword)  && sms_vendor.help_keyword.present?
      sms_vendor.default_keyword.update_attribute :response_text, sms_vendor.read_attribute(:help_text) if sms_vendor.respond_to?(:default_keyword)  && sms_vendor.default_keyword.present?
    end
  end

  def down
  end
end
