##
# A MessageType is used to categorize messages for systems querying downstream (such as Evolution).
# Message types have codes, which are write-only and used to identify the types uniquely in other systems.
# Message types also have labels, which are mutable, and are intended to be displayed in a user-interface.
#

class MessageType < ActiveRecord::Base
  belongs_to :account
  has_many :email_messages

  attr_accessible :label, :code

  validates :code,
            presence:   true,
            format: {with: /\A[a-zA-Z0-9_]*\z/, message: "only letters, numbers and underscores are allowed"},
            length:     {maximum: 255},
            uniqueness: {scope: :account, case_sensitive: false}
  validates :label, presence: true, length: {maximum: 255}

  validate :code_not_changed

  before_validation :ensure_label
  before_destroy :ensure_no_messages

  private

  def ensure_label
    self.label ||= code.try :titleize
  end

  def ensure_no_messages
    if email_messages.exists?
      errors.add(:base, 'Cannot be destroyed because email messages exist with this message type')
      false
    end
  end

  def code_not_changed
    if code_changed? && persisted?
      errors.add(:code, "changing is not allowed")
    end
  end
end
