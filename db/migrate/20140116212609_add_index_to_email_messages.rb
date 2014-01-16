class AddIndexToEmailMessages < ActiveRecord::Migration
  def change
    #   CREATE INDEX em_idx3 
    #       ON email_messages (user_id, created_at, status, subject, id) 
    #   ONLINE

    # If you aren't running enterprise edition, you get ORA-00439
    # because online index building is an enterprise feature.
    online = ['development', 'test'].include?(Rails.env) ? '' : 'ONLINE'
    
    add_index :email_messages, 
              [:user_id, :created_at, :status, :subject, :id], 
              name: 'em_idx3',
              options: online
  end
end