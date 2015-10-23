class SmsTemplate < ActiveRecord::Base
  belongs_to :account
  belongs_to :user
  has_many :sms_messages

  attr_accessible :body

  before_validation :set_defaults, on: :create

  validates :body, presence: true, length: {maximum: 160}
  validates :user, presence: true
  validates :account, presence: true

  validate :user_belongs_to_account

  protected

  def set_defaults
    self.account ||= user.account if user
  end

  def user_belongs_to_account
    errors.add(:user, 'must belong to same account as sms template') unless account && account.users.where(id: user_id).any?
  end
end
