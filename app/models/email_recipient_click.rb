class EmailRecipientClick < ActiveRecord::Base
  include EmailRecipientMetric

  attr_accessible :url, :email
  validates :url, presence: true, length: { maximum: 4000 }
  validates_presence_of :clicked_at

  # This scope is designed to come purely from an index (and avoid hitting the table altogether).
  # On the other hand, the inclusion of URL forces this query to
  # go off to the table to fetch it. Oh well.
  scope :indexed, -> { select('email_message_id, email_recipient_id, clicked_at, id, url') }
end
