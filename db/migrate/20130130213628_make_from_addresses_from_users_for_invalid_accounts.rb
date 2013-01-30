class MakeFromAddressesFromUsersForInvalidAccounts < ActiveRecord::Migration
  def change
    Account.includes(:from_address).where('from_addresses.id IS NULL AND email_vendor_id IS NOT NULL').each do |account|
      user = account.users.first
      account.create_from_address!(from_email: user.email)
      puts "updated #{account.name} from address to #{user.email}"
    end
  end
end
