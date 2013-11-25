class AddFromEmailToEmailMessages < ActiveRecord::Migration
  def change
    # no need to backfill this data. 
    add_column :email_messages, :from_email, :string
  end
end
