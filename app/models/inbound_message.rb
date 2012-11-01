class InboundMessage < ActiveRecord::Base
  belongs_to :vendor
  paginates_per 50

  attr_accessible :body, :from, :vendor
  validates_presence_of :body, :from, :vendor_id
  alias_attribute :from, :from_phone # 'from_phone' is the database column, as 'from' is a reserved word in Oracle (who knew?)

  def to
    vendor.from
  end

end
