Object.send(:remove_const, :Vendor) if defined?(Vendor)
require 'vendor'
class FixSmsVendorNumbers < ActiveRecord::Migration
  def change
    SmsVendor.find_each do |v|
      puts (if v.save
              "Updated #{v.name} number to #{v.from_phone}"
            else
              "Problem updating #{v}: #{v.errors.full_messages}"
            end)
    end
  end
end
