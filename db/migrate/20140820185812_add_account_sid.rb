class AddAccountSid < ActiveRecord::Migration
  def change
    add_column :accounts, :sid, :string, limit: 32
    Account.all.each do |account|
      account.send(:generate_sid)
      account.save!
    end
    change_column :accounts, :sid, :string, limit: 32, null: false
  end
end
