class AddEmailTemplateAssociationToEmailMessage < ActiveRecord::Migration
  def change
    add_belongs_to  :email_messages, :email_template, index: true
  end
end
