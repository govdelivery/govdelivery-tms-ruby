class CreateEventHandlers < ActiveRecord::Migration
  class Account < ActiveRecord::Base
    has_one :stop_keyword, :class_name => 'Keyword', :conditions => {:stop => true}
  end
  class Action < ActiveRecord::Base
    belongs_to :event_handler
  end
  class Keyword < ActiveRecord::Base
    has_many :actions
    belongs_to :event_handler
  end
  def up
    create_table :event_handlers do |t|
      t.timestamps
    end
    add_column :accounts, :stop_handler_id, :integer
    add_column :actions, :event_handler_id, :integer
    add_column :keywords, :event_handler_id, :integer

    Keyword.all.each do |kw|
      handler = kw.build_event_handler
      handler.actions = kw.actions
      kw.save!
    end

    Account.all.each do |a|
      a.stop_handler = a.stop_keyword.event_handler
      a.save!
      a.stop_keyword.destroy
    end

    remove_column :actions, :keyword_id
    remove_column :keywords, :stop
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
