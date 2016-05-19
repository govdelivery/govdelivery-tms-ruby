class AddMessageTypeToEmailTemplates < ActiveRecord::Migration
  def change
    add_column :email_templates, :message_type_id, :integer
  end
end
