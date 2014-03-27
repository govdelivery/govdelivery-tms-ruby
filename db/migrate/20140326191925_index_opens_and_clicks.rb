class IndexOpensAndClicks < ActiveRecord::Migration
  def up
    # If you aren't running enterprise edition, you get ORA-00439
    # because online index building is an enterprise feature.
    online = ['development', 'test'].include?(Rails.env) ? '' : 'ONLINE'

    safely do
      remove_index :email_recipient_opens, name: 'ero_idx1'
    end

    safely do
      add_index :email_recipient_opens,
                [:email_message_id, :email_recipient_id, :id, :opened_at],
                name: 'ero_idx1',
                options: online
    end

    safely do
      remove_index :email_recipient_clicks, name: 'erc_idx1'
    end

    safely do
      add_index :email_recipient_clicks,
                [:email_message_id, :email_recipient_id, :id, :clicked_at],
                name: 'erc_idx1',
                options: online
    end
  end

  def safely
    begin
      yield 
    rescue Exception => e
      puts "Swallowed error: #{e}"
    end
  end

  def down
    remove_index :email_recipient_opens, name: 'ero_idx1'
    remove_index :email_recipient_clicks, name: 'erc_idx1'
  end
end
