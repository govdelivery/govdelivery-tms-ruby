class CommandAction < ActiveRecord::Base
  attr_accessible :command_id, :inbound_message_id, :http_response_code, :http_content_type, :http_body
  strip_attributes

  belongs_to :command
  belongs_to :inbound_message
  validates :inbound_message, presence: true
  validates :http_response_code, presence: true
  validates :http_content_type, presence: true

  before_validation :trim_body, on: :create
  after_create :update_inbound_message

  scope :successes, where("http_response_code BETWEEN 200 AND 299")

  def plaintext_body?
    self.http_content_type=~/text\/plain/ && !self.http_body.blank?
  end

  protected

  def trim_body
    self.http_body = nil if http_body && http_body.length > 500
  end

  def update_inbound_message
    inbound_message.check_status!
  end

end
