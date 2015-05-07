class DropTrackingEnabledDefaults < ActiveRecord::Migration
  def change
    change_column_default :email_messages, :open_tracking_enabled, nil
    change_column_default :email_messages, :click_tracking_enabled, nil
  end
end
