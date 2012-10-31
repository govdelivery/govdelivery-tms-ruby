class InboundMessage < ActiveRecord::Base
  belongs_to :vendor

  attr_accessible :body, :from, :vendor
  validates_presence_of :body, :from, :vendor_id

  def to
    vendor.from
  end
end
