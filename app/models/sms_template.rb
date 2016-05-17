class SmsTemplate < ActiveRecord::Base
  belongs_to :account
  belongs_to :user
  has_many :sms_messages

  attr_accessible :body, :uuid

  before_validation :set_defaults, on: :create

  validates :body, presence: true, length: {maximum: 160}
  validates :user, presence: true
  validates :account, presence: true
  validates :uuid,
            length: {maximum: 128},
            format: {with: /\A[a-zA-Z0-9_-]*\z/, message: "only letters, numbers, -, and _ are allowed"},
            uniqueness: {scope: :account, case_sensitive: false}

  validate :user_belongs_to_account
  validate :id_and_uuid_cannot_change

  after_create :set_uuid

  def to_param
    uuid
  end

  protected

  def set_defaults
    self.account ||= user.account if user
  end

  def set_uuid
    self.uuid = id if uuid.blank?
    save!
  end

  def id_and_uuid_cannot_change
    if changed.include?("uuid")
      errors.add(:uuid, 'cannot be updated') unless new_record? || changed_attributes["uuid"].nil? || changed_attributes["uuid"].empty?
    end
  end

  def user_belongs_to_account
    errors.add(:user, 'must belong to same account as sms template') unless account && account.users.where(id: user_id).any?
  end
end
