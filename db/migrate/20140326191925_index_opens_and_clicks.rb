class IndexOpensAndClicks < ActiveRecord::Migration
  def up
    # If you aren't running enterprise edition, you get ORA-00439
    # because online index building is an enterprise feature.
    online = ['development', 'test'].include?(Rails.env) ? '' : 'ONLINE'

    begin
      add_index :email_recipient_opens,
                [:email_recipient_id, :email_message_id, :id, :opened_at],
                name: 'ero_idx1',
                options: online
    rescue => e
      puts "Something went wrong: #{e}"
    end

    begin
      add_index :email_recipient_clicks,
                [:email_recipient_id, :email_message_id, :id, :clicked_at, :url],
                name: 'erc_idx1',
                options: online
    rescue => e
      puts "Something went wrong: #{e}"
    end
  end

  def down
  end
end
