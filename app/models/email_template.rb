class EmailTemplate < ActiveRecord::Base
  include HasLinkTrackingParameters
  include MessageTypeSetter
  belongs_to :account
  belongs_to :user
  belongs_to :from_address
  belongs_to :message_type
  has_many :email_messages
  serialize :macros

  attr_accessible :from_address_id, :body, :subject, :link_tracking_parameters, :open_tracking_enabled, :click_tracking_enabled, :macros, :uuid

  before_validation :set_defaults, on: :create

  validates :body, presence: true
  validates :subject, presence: true
  validates :from_address, presence: true
  validates :user, presence: true
  validates :account, presence: true
  validate :user_and_address_belong_to_account
  validate :valid_macros
  validate :liquid_markup_valid
  validates :open_tracking_enabled, :click_tracking_enabled, inclusion: {in: [true, false]}
  validates :uuid,
            length: {maximum: 128},
            format: { with: /\A[a-zA-Z0-9_-]*\z/, message: "only letters, numbers, -, and _ are allowed" },
            uniqueness: {scope: :account, case_sensitive: false}

  validate :id_and_uuid_cannot_change
  before_update :auto_remove_message_type # this must come before auto_create_message_type
  before_update :auto_create_message_type # change message type or change label
  before_create :auto_create_message_type # create or set message type

  after_create :set_uuid

  def to_param
    uuid
  end

  protected

  def valid_macros
    errors.add(:macros, 'must be a hash or null') unless try(:macros).nil? || macros.is_a?(Hash)
  end

  def liquid_markup_valid
    begin
      template = Liquid::Template.parse(body, :error_mode => :warn)
    rescue Liquid::SyntaxError => error
      self.errors.add(:body, 'cannot include invalid Liquid markup')
    end
  end

  def set_uuid
    update_attribute :uuid, id if uuid.blank?
  end

  def id_and_uuid_cannot_change
    if changed.include?("uuid")
      errors.add(:uuid, 'cannot be updated') unless new_record? || changed_attributes["uuid"].nil? || changed_attributes["uuid"].empty?
    end
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
