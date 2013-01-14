class CreateSmsMessages < ActiveRecord::Migration
  def change
    create_table :sms_messages do |t|
      t.string :body
      t.datetime :created_at
      t.time :completed_at
      t.references :user
      t.references :account
    end
  end
end
