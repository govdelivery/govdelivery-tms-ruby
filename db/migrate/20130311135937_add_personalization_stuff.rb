class AddPersonalizationStuff < ActiveRecord::Migration
  def up
    add_column :email_recipients, :macros, :text
    add_column :email_messages, :macros, :text
  end

  def down
    remove_column :email_recipients, :macros
    remove_column :email_messages, :macros
  end
end
