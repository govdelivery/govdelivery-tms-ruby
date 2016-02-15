class SmsTemplate < ActiveRecord::Base
  belongs_to :account
  belongs_to :user
  has_many :sms_messages

  attr_accessible :body

  before_validation :set_defaults, on: :create

  validates :body, presence: true, length: {maximum: 160}
  validates :user, presence: true
  validates :account, presence: true
  validates :uuid,
            length: {maximum: 128},
            format: { with: /\A[a-zA-Z0-9_-]*\z/, message: "only letters, numbers, -, and _ are allowed" },
            uniqueness: {scope: :account, case_sensitive: false}

  validate :user_belongs_to_account

  after_create :set_uuid

  protected

  def set_defaults
    self.account ||= user.account if user
  end

  def set_uuid
    self.uuid ||= self.id
    self.save!
  end

  def user_belongs_to_account
    errors.add(:user, 'must belong to same account as sms template') unless account && account.users.where(id: user_id).any?
  end
end
