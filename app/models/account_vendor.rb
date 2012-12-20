class AccountVendor < ActiveRecord::Base
  attr_accessible :account, :vendor
  belongs_to :account
  belongs_to :vendor
  
end
