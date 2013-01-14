class InboundMessage < ActiveRecord::Base
  belongs_to :vendor, :inverse_of => :inbound_messages, :class_name=>'SmsVendor'
  paginates_per 50

  attr_accessible :body, :from, :vendor, :to
  validates_presence_of :body, :from, :vendor
  alias_attribute :from, :caller_phone # 'from_phone' is the database column, as 'from' is a reserved word in Oracle (who knew?)
  alias_attribute :to, :vendor_phone

end
