class FromNumber < ActiveRecord::Base
  belongs_to :account, :inverse_of => :from_numbers
  has_many :incoming_voice_messages
  has_one :default_incoming_voice_message, -> { where(is_default: true).order('created_at DESC') }, class_name: IncomingVoiceMessage
  attr_accessible :phone_number, :is_default
  alias_attribute :from_number, :phone_number

  before_validation :normalize_phone_number
  validates :phone_number, presence: true, uniqueness: {scope: :account_id}

  before_save :ensure_unique_defaultness

  def voice_message

  end

  protected
  ##
  # There should only be one default from number at a given time.
  #
  def ensure_unique_defaultness(*args)
    if current_default = account.from_numbers.where(is_default: true).first
      if (self.is_default? && current_default != self)
        current_default.update_attributes(is_default: false)
      end
    else
      self.is_default = true
    end
  end
  def normalize_phone_number
    self.phone_number = PhoneNumber.new(phone_number).e164_or_short
  end
end
