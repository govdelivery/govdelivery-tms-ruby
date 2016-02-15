class AddUuidToEmailTemplate < ActiveRecord::Migration
  def change
    add_column :email_templates, :uuid, :string
    EmailTemplate.update_all("uuid = id")
    add_index :email_templates, [:account_id, :uuid], :unique => true
  end
end
