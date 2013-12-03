Account.reset_column_information
class MakeFromAddressesFromUsersForInvalidAccounts < ActiveRecord::Migration
  def change
    if Account.new.respond_to?(:from_address)
      Account.includes(:from_address).where('from_addresses.id IS NULL AND email_vendor_id IS NOT NULL').each do |account|
        user = account.users.first
        account.create_from_address!(from_email: user.email)
        puts "updated #{account.name} from address to #{user.email}"
      end
    end
  end
end
