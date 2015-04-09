class AddStatusColumnsToMessageTables < ActiveRecord::Migration
  class SmsMessage < ActiveRecord::Base; end
  class VoiceMessage < ActiveRecord::Base; end
  def change
    [SmsMessage, VoiceMessage].each do |model|
      add_column model.table_name, :status, :string, null: false, default: 'new'
      model.all.each do |msg|
        msg.status = 'completed'
        msg.save!
      end
    end
  end
end
