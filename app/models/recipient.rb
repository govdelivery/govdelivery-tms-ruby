class Recipient < ActiveRecord::Base
  module Scopes
    def incomplete
      where(:ack => nil)
    end
  end
  extend Scopes
  
  attr_accessible :phone, :ack, :completed

  belongs_to  :message

  validates_length_of :ack, :maximum => 256
  validates_numericality_of :phone, :only_integer => true
  validates_uniqueness_of :phone, :scope => "message_id"
end
