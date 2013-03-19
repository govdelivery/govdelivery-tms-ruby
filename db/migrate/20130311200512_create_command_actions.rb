class CreateCommandActions < ActiveRecord::Migration
  def change
    create_table :command_actions do |t|
      t.references :command
      t.references :inbound_message
      t.integer :http_response_code
      t.string :http_content_type, :limit => 100
      t.string :http_body, :limit => 500
      t.datetime :created_at, :null => false
    end

    change_table :inbound_messages do |t|
      t.references :keyword
      t.string :keyword_response
      t.string :command_status, limit: 15
    end
  end
end
