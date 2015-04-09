class AddDcmAccountCodesToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :dcm_account_codes, :string, limit: 4000
  end
end
