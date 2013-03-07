class AddTrackingBoolsToEmailMessage < ActiveRecord::Migration
  def change
    add_column :email_messages, :open_tracking_enabled, :boolean, :default => true
    add_column :email_messages, :click_tracking_enabled, :boolean, :default => true
  end
end
