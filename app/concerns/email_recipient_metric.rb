module EmailRecipientMetric
  extend ActiveSupport::Concern

  included do
    belongs_to :email_message
    belongs_to :email_recipient

    validates_presence_of :email_message
    validates_presence_of :email_recipient

    validates :email, presence: true, length: {maximum: 256}
  end
end