module EmailRecipientMetric
  extend ActiveSupport::Concern

  included do
    belongs_to :email_message
    belongs_to :email_recipient

    validates :email_message, presence: true
    validates :email_recipient, presence: true

    validates :email, presence: true, length: {maximum: 256}
  end
end
