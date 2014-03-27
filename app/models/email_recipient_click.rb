class EmailRecipientClick < ActiveRecord::Base
  include EmailRecipientMetric

  validates :url, :presence => true, length: {maximum: 4000}
  validates_presence_of :clicked_at

  # This scope is designed to come purely from an index (and avoid hitting the table altogether)
  scope :indexed, select("email_recipient_id, email_message_id, clicked_at, id, url")
end