class EmailTemplate < ActiveRecord::Base
  belongs_to :account
  belongs_to :user
  belongs_to :from_address
  has_many :email_messages
  serialize :macros

  attr_accessible :from_address_id, :body, :subject, :link_tracking_parameters, :open_tracking_enabled, :click_tracking_enabled, :macros

  validates :body, presence: true
  validates :subject, presence: true
  validates :from_address, presence: true
  validates :user, presence: true
  validates :account, presence: true
  validate :user_and_address_belong_to_account
  validate :valid_macros

  def valid_macros
    errors.add(:macros, 'must be a hash or null') unless try(:macros).nil? || macros.is_a?(Hash)
  end

  def user_and_address_belong_to_account
    errors.add(:from_address, 'must belong to same account as email template') unless account && account.from_addresses.where(id: from_address_id).any?
    errors.add(:user, 'must belong to same account as email template') unless account && account.users.where(id: user_id).any?
  end
end
