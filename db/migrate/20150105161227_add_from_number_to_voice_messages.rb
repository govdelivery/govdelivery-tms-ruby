class AddFromNumberToVoiceMessages < ActiveRecord::Migration
  def change
    add_column :voice_messages, :from_number, :string
  end
end
