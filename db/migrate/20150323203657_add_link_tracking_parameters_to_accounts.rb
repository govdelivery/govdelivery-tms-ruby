class AddLinkTrackingParametersToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :link_tracking_parameters, :string
  end
end
