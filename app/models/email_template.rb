class EmailTemplate < ActiveRecord::Base
  include HasLinkTrackingParameters
  belongs_to :account
  belongs_to :user
  belongs_to :from_address
  has_many :email_messages
  serialize :macros

  attr_accessible :from_address_id, :body, :subject, :link_tracking_parameters, :open_tracking_enabled, :click_tracking_enabled, :macros

  before_validation :set_defaults, on: :create

  validates :body, presence: true
  validates :subject, presence: true
  validates :from_address, presence: true
  validates :user, presence: true
  validates :account, presence: true
  validate :user_and_address_belong_to_account
  validate :valid_macros
  validates :open_tracking_enabled, :click_tracking_enabled, inclusion: {in: [true, false]}

  protected

  def valid_macros
    errors.add(:macros, 'must be a hash or null') unless try(:macros).nil? || macros.is_a?(Hash)
  end

  def user_and_address_belong_to_account
    errors.add(:from_address, 'must belong to same account as email template') unless account && account.from_addresses.where(id: from_address_id).any?
    errors.add(:user, 'must belong to same account as email template') unless account && account.users.where(id: user_id).any?
  end

  def set_defaults
    self.account      ||= user.account if user
    self.from_address ||= account.default_from_address if user
    self.open_tracking_enabled = true if open_tracking_enabled.nil?
    self.click_tracking_enabled = true if click_tracking_enabled.nil?
  end

end
