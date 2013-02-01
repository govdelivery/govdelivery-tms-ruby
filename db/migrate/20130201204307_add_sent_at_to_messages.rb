class AddSentAtToMessages < ActiveRecord::Migration
  def change
    [:voice_messages, :sms_messages, :email_messages].each do |tablename|
      add_column tablename, :sent_at, :datetime
    end
  end
end
