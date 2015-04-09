module Vendor
  extend ActiveSupport::Concern

  included do
    attr_accessible :name, :username, :password, :worker
    has_many :accounts, foreign_key: name.foreign_key
    has_many :recipients, class_name: name.gsub('Vendor', 'Recipient'), foreign_key: 'vendor_id'
    validates_presence_of [:name, :username, :password, :worker]

    validates_uniqueness_of :name
    validates_length_of [:name, :username, :password, :worker], maximum: 256
  end
end
