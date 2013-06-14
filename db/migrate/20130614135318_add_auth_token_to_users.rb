class AddAuthTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :authentication_token, :string, limit: 255
    add_index :users, :authentication_token, :unique => true

    # The following lines are to generate authentication tokens for existing users
    User.reset_column_information
    User.all.map(&:save!)
  end
end
