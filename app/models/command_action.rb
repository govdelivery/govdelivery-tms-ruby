class CommandAction < ActiveRecord::Base
  attr_accessible :status, :content_type, :response_body, :error_message
  strip_attributes

  belongs_to :command
  belongs_to :inbound_message
  validates :inbound_message, presence: true
  validates :status, presence: true, if: 'error_message.nil?'
  validates :error_message, length: { maximum: 255 }
  validates :error_message, presence: true, if: 'status.nil?'

  before_validation :trim_body, on: :create
  after_save :update_inbound_message

  scope :successes, where('status BETWEEN 200 AND 299')

  def success?
    (200..299).include?(status) && response_body.present?
  end

  def fail?
    !success?
  end

  protected

  # over 500 characters will result in a failure
  def trim_body
    self.response_body = nil if response_body && response_body.length > 500
  end

  def update_inbound_message
    inbound_message.update_status!(fail?)
  end
end
