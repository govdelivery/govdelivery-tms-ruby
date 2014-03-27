class EmailRecipientOpen < ActiveRecord::Base 
  include EmailRecipientMetric

  validates :event_ip, :presence => true, length: {maximum: 256}
  validates_presence_of :opened_at

  # This scope is designed to come purely from an index (and avoid hitting the table altogether)
  scope :indexed, select("email_recipient_id, email_message_id, opened_at, id")
end
