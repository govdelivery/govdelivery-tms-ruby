class User < ActiveRecord::Base
  devise :database_authenticatable, :validatable
  acts_as_multi_token_authenticatable

  attr_accessible :email, :password

  belongs_to :account
  has_many :authentication_tokens, dependent: :delete_all

  validates :account, presence: true
  validates :email, presence: true, length: {maximum: 256}, uniqueness: {scope: :account_id}

  has_many :email_messages, -> {order('email_messages.created_at DESC')}
  has_many :account_email_messages, through: :account, source: EmailMessage.table_name
  has_many :sms_messages, -> {order('sms_messages.created_at DESC')}
  has_many :account_sms_messages, through: :account, source: SmsMessage.table_name
  has_many :voice_messages, -> {order('voice_messages.created_at DESC')}
  has_many :account_voice_messages, through: :account, source: VoiceMessage.table_name
  has_many :email_templates
  has_many :sms_templates
  has_one :one_time_session_token, dependent: :delete

  scope :for_token, ->(token) {joins(:authentication_tokens).where('authentication_tokens.token' => token)}

  before_validation :downcase_email

  delegate :vendors, to: :account
  delegate :sms_vendor, to: :account
  delegate :voice_vendor, to: :account

  def self.with_token(token)
    for_token(token).first
  end

  def to_s
    email.downcase
  end

  delegate :indexed, to: :email_messages, prefix: true

  def after_database_authentication
    logger.info("logged in as #{self}")
  end

  def one_time_session_token
    # Using delete instead of destroy because destroy will attempt to validate with user_id = nil, which throws a validation error
    @one_time_session_token.delete if @one_time_session_token
    create_one_time_session_token
  end

  private

  def downcase_email
    email.downcase! if email
  end
end
