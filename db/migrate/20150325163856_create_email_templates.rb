class CreateEmailTemplates < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.text :body, null: false
      t.string :subject, null: false
      t.string :link_tracking_parameters
      t.text :macros
      t.references :user
      t.references :account
      t.references :from_address
      t.boolean :open_tracking_enabled, default: true, null: false
      t.boolean :click_tracking_enabled, default: true, null: false
      t.timestamps
    end
  end
end
