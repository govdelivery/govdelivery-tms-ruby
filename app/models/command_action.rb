class CommandAction < ActiveRecord::Base
  attr_accessible :command_id, :inbound_message_id, :status, :content_type, :response_body
  strip_attributes

  belongs_to :command
  belongs_to :inbound_message
  validates :inbound_message, presence: true

  before_validation :trim_body, on: :create
  after_save :update_inbound_message

  scope :successes, where("status BETWEEN 200 AND 299")

  def plaintext_body?
    success? && self.content_type=~/text\/plain/ && !self.response_body.blank?
  end

  def success?
    (200..299).include?(status)
  end

  protected

  def trim_body
    self.response_body = nil if response_body && response_body.length > 500
  end

  def update_inbound_message
    inbound_message.check_status!
  end

end