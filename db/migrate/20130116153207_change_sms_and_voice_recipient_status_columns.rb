class ChangeSmsAndVoiceRecipientStatusColumns < ActiveRecord::Migration
  class SmsRecipient < ActiveRecord::Base; end
  class VoiceRecipient < ActiveRecord::Base; end

  INTS_TO_STRINGS = {
    1 => 'new',
    2 => 'sending',
    3 => 'sent',
    4 => 'failed',
    5 => 'blacklisted',
    6 => 'canceled'
  }

  def up
    [SmsRecipient, VoiceRecipient].each do |model|
      rename_column model.table_name, :status, :old_status
      add_column model.table_name, :status, :string, null: false, default: 'new'
      INTS_TO_STRINGS.each do |int, string|
        puts "Changing status from #{int} to #{string}"
        puts model.where(old_status: int).update_all(status: string)
      end
      remove_column model.table_name, :old_status
    end
  end

  def down
    [SmsRecipient, VoiceRecipient].each do |model|
      rename_column model.table_name, :status, :old_status
      add_column model.table_name, :status, :integer, null: false, default: 1
      INTS_TO_STRINGS.each do |int, string|
        puts "Changing status from #{string} to #{int}"
        puts model.where(old_status: string).update_all(status: int)
      end
      remove_column model.table_name, :old_status
    end
  end
end
