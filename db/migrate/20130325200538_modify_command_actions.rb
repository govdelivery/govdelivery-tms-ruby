class ModifyCommandActions < ActiveRecord::Migration

  def change
    change_table(:command_actions) do |t|
      t.rename :http_response_code, :status
      t.rename :http_content_type, :content_type
      t.rename :http_body, :response_body
    end
  end
end
