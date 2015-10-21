class CreateSmsTemplates < ActiveRecord::Migration
  def change
    create_table :sms_templates do |t|
      t.text :body, null: false
      t.references :user
      t.references :account
      t.timestamps
    end
  end
end
