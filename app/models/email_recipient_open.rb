class EmailRecipientOpen < ActiveRecord::Base 
  include EmailRecipientMetric

  attr_accessible
  validates :event_ip, presence: true, length: {maximum: 256}
  validates_presence_of :opened_at

  # This scope is designed to come purely from an index (and avoid hitting the table altogether)
  scope :indexed, -> { select("email_message_id, email_recipient_id, opened_at, id") }
end
