class RenameActivitySequence < ActiveRecord::Migration
  def up
    rename_column :email_vendors, :activities_sequence, :deliveries_sequence
  end

  def down
    rename_column :email_vendors, :deliveries_sequence, :activities_sequence
  end
end
