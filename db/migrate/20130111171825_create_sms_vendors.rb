class Vendor < ActiveRecord::Base
  attr_accessible :name, :username, :password, :worker, :help_text, :stop_text, :voice, :vtype

  enum :vtype, [:sms, :voice, :email]

  DEFAULT_HELP_TEXT = "Go to http://bit.ly/govdhelp for help"
  DEFAULT_STOP_TEXT = "You will no longer receive SMS messages."
  RESERVED_KEYWORDS = %w(stop quit help)

  has_many :keywords
  has_many :account_vendors
  has_many :accounts, :through => :account_vendors
  has_many :stop_requests
  has_many :inbound_messages, :include => :vendor
  has_many :recipients
end

class CreateSmsVendors < ActiveRecord::Migration
  def change
    Vendor.where(:vtype => 'voice').each do |v|
      VoiceVendor.create!(:name => v.name, :worker => v.worker, :username => v.username, :password => v.password, :from=>v.from)
      v.accounts.each do |a|
        v.update_attribute(:voice_vendor_id, v.id)
      end
    end

    add_column :accounts, :sms_vendor_id, :integer

    Vendor.where(:vtype => 'sms').each do |v|
      v.accounts.each do |a|
        v.update_attribute(:sms_vendor_id, v.id)
      end
    end

    remove_column :vendors, :vtype
    remove_column :vendors, :voice
    rename_column :vendors, :from, :from_phone
    rename_table :vendors, :sms_vendors
    drop_table :account_vendors
  end
end
