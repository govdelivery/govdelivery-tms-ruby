class DropTrackingEnabledDefaultsOnEmailTemplate < ActiveRecord::Migration
  def change
    change_column_default :email_templates, :open_tracking_enabled, nil
    change_column_default :email_templates, :click_tracking_enabled, nil
  end
end
