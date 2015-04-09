class Message2 < ActiveRecord::Base
  self.table_name = 'messages'
  belongs_to :user
  belongs_to :account
end

class AddAccountToMessages < ActiveRecord::Migration
  def change
    add_column(:messages, :account_id, :integer)
    Message2.reset_column_information
    Message2.find_each do |m|
      m.account_id = m.user.account_id
      m.save!
    end
    change_column(:messages, :account_id, :integer, null: false)
    change_column(:messages, :user_id, :integer, null: true)
  end
end
