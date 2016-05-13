##
# A MessageType is used to categorize messages for systems querying downstream (such as Evolution).
# Message types have keys, which are write-only and used to identify the types uniquely in other systems.
# Message types also have names, which are mutable, and are intended to be displayed in a user-interface.
#

class MessageType < ActiveRecord::Base
  belongs_to :account

  validates :name_key,
            presence:   true,
            format: { with: /\A[a-zA-Z0-9_]*\z/, message: "only letters, numbers and underscores are allowed" },
            length:     {maximum: 255},
            uniqueness: {scope: :account, case_sesitive: false}
  validates :name, presence: true, length: {maximum: 255}

  validate :name_key_not_changed

  private

  def name_key_not_changed
    if self.name_key_changed? && self.persisted?
      errors.add(:name_key, "changing is not allowed")
    end
  end
end
