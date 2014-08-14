class CreateWebhooks < ActiveRecord::Migration
  def change
    create_table :webhooks do |t|
      t.references :account
      t.string :event_type, limit: 30
      t.string :url
      t.timestamps
    end
  end
end
