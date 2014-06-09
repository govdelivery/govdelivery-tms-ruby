class DataMigrationMoveResponseTextToKeywords < ActiveRecord::Migration
  def up
    Account.all.each do |account|
      account.reload #to ensure special keywords exist
      account.save!
      account.stop_keyword.update_attribute :response_text, account.read_attribute(:stop_text)
      account.help_keyword.update_attribute :response_text, account.read_attribute(:help_text)
      account.default_keyword.update_attribute :response_text, account.read_attribute(:help_text)
      account.stop_keyword.commands << account.stop_handler.commands
    end
    SmsVendor.all.each do |sms_vendor|
      sms_vendor.reload #to ensure special keywords exist
      sms_vendor.save!
      sms_vendor.stop_keyword.update_attribute :response_text, sms_vendor.read_attribute(:stop_text)
      sms_vendor.help_keyword.update_attribute :response_text, sms_vendor.read_attribute(:help_text)
      sms_vendor.default_keyword.update_attribute :response_text, sms_vendor.read_attribute(:help_text)
      # start doesn't exist yet
      # there are no commands to be moved to these keywords
    end
    #custom commands
    Command.all.each do |command|
      keyword = command.event_handler.try(:keyword)
      next unless keyword and puts " #{command.name}"
      puts "#{command.name} => #{keyword.name}"
      keyword.commands << command
    end
  end

  def down
  end
end
