class AccountVendor < ActiveRecord::Base
  belongs_to :account
  belongs_to :vendor
  
end
