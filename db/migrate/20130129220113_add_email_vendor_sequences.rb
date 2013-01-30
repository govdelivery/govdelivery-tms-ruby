class AddEmailVendorSequences < ActiveRecord::Migration
  def change
    add_column :email_vendors, :activities_sequence, :string
    add_column :email_vendors, :clicks_sequence, :string
    add_column :email_vendors, :opens_sequence, :string
  end
end
