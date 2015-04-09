class User < ActiveRecord::Base
  devise :database_authenticatable, :validatable
  acts_as_multi_token_authenticatable

  attr_accessible :email, :password

  belongs_to :account
  has_many :authentication_tokens, dependent: :delete_all

  validates_presence_of :account
  validates_presence_of :email
  validates_length_of :email, maximum: 256
  validates_uniqueness_of :email, scope: :account_id

  has_many :email_messages, -> { order('email_messages.created_at DESC') }
  has_many :account_email_messages, through: :account, source: EmailMessage.table_name
  has_many :sms_messages, -> { order('sms_messages.created_at DESC') }
  has_many :account_sms_messages, through: :account, source: SmsMessage.table_name
  has_many :voice_messages, -> { order('voice_messages.created_at DESC') }
  has_many :account_voice_messages, through: :account, source: VoiceMessage.table_name
  has_many :email_templates

  scope :for_token, ->(token) { joins(:authentication_tokens).where('authentication_tokens.token' => token) }

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

  def email_messages_indexed
    email_messages.indexed
  end

  def after_database_authentication
    logger.info("logged in as #{self}")
  end

  private

  def downcase_email
    email.downcase! if email
  end
end
