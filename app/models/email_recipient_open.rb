class EmailRecipientOpen < ActiveRecord::Base 
  include EmailRecipientMetric

  validates :event_ip, :presence => true, length: {maximum: 256}
  validates_presence_of :opened_at
end
