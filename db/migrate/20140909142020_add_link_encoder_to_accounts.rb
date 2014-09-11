class AddLinkEncoderToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :link_encoder, :string, limit: 30
  end
end
