class DataMigrationMoveResponseTextToKeywords < ActiveRecord::Migration
  def up
    Account.all.select { |a| a.sms_vendor.present? }.each do |account|
      account.create_stop_keyword! if account.stop_keyword.nil?
      account.create_help_keyword! if account.help_keyword.nil?
      account.create_default_keyword! if account.default_keyword.nil?
      account.stop_keyword.update_attribute :response_text, account.read_attribute(:stop_text) if account.stop_keyword.response_text.nil?
      account.help_keyword.update_attribute :response_text, account.read_attribute(:help_text) if account.help_keyword.response_text.nil?
      account.default_keyword.update_attribute :response_text, account.read_attribute(:help_text) if account.default_keyword.response_text.nil?
      account.default_keyword.update_attribute :response_text, Keywords::DEFAULT_HELP_TEXT if account.default_keyword.response_text.nil?
      # stop_handler -> stop_keyword
      if account.stop_handler
        account.stop_handler.commands.each do |command|
          command.update_attribute :keyword_id, account.stop_keyword.id # to avoid validation errors (there were some in qc)
        end
      end
    end
    SmsVendor.all.each do |sms_vendor|
      sms_vendor.create_stop_keyword! if sms_vendor.stop_keyword.nil?
      sms_vendor.create_start_keyword! if sms_vendor.start_keyword.nil?
      sms_vendor.create_help_keyword! if sms_vendor.help_keyword.nil?
      sms_vendor.create_default_keyword! if sms_vendor.default_keyword.nil?
      sms_vendor.stop_keyword.update_attribute :response_text, sms_vendor.read_attribute(:stop_text) if sms_vendor.stop_keyword.response_text.nil?
      sms_vendor.start_keyword.update_attribute :response_text, Keywords::DEFAULT_START_TEXT  if sms_vendor.start_keyword.response_text.nil?
      sms_vendor.help_keyword.update_attribute :response_text, sms_vendor.read_attribute(:help_text) if sms_vendor.help_keyword.response_text.nil?
      sms_vendor.default_keyword.update_attribute :response_text, sms_vendor.read_attribute(:help_text)  if sms_vendor.default_keyword.response_text.nil?
      sms_vendor.default_keyword.update_attribute :response_text, Keywords::DEFAULT_HELP_TEXT  if sms_vendor.default_keyword.response_text.nil?
    end
    # custom commands
    Command.all.each do |command|
      keyword = command.event_handler.try(:keyword)
      next unless keyword && puts(" #{command.name}")
      puts "#{command.name} => #{keyword.name}"
      command.update_attribute! :keyword_id, keyword.id
    end
  end

  def down
    Keyword.special.delete_all
  end
end
