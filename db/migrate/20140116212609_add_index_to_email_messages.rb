class AddIndexToEmailMessages < ActiveRecord::Migration
  def change
    #   CREATE INDEX em_idx3
    #       ON email_messages (user_id, created_at, status, subject, id)
    #   ONLINE

    # If you aren't running enterprise edition, you get ORA-00439
    # because online index building is an enterprise feature.
    online = %w(development test).include?(Rails.env) ? '' : 'ONLINE'

    begin
      add_index :email_messages,
                [:user_id, :created_at, :status, :subject, :id],
                name: 'em_idx4',
                options: online
      rescue => e
        puts "Something went wrong: #{e}"
    end
  end
end
