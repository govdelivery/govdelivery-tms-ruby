class AddIsDefaultToFromAddresses < ActiveRecord::Migration
  def change
    add_column :from_addresses, :is_default, :boolean, :default => false
    # all existing from addresses are defaults, because the account/from_address 
    # relationship used to be has_one. 
    FromAddress.update_all(is_default: true)
  end

end
