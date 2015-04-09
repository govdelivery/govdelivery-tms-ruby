class CreateEmailMessages < ActiveRecord::Migration
  def change
    create_table :email_messages do |t|
      t.references :user
      t.references :account
      t.text :body
      t.string :status, null: false, default: 'new'
      t.string :from_name
      t.string :subject, limit: 400
      t.time :completed_at
      t.timestamps
    end
  end
end
