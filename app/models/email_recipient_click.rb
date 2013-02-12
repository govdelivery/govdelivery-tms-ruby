class EmailRecipientClick < ActiveRecord::Base
  include EmailRecipientMetric

  validates :url, :presence => true, length: {maximum: 4000}
  validates_presence_of :clicked_at
end