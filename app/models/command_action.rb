class CommandAction < ActiveRecord::Base
  attr_accessible :command_id, :inbound_message_id, :http_response_code, :http_content_type, :http_body
  belongs_to :command
  belongs_to :inbound_message

  validates :inbound_message, presence: true
  validates :http_response_code, presence: true
  validates :http_content_type, presence: true

  after_create :update_inbound_message

  scope :successes, where("http_response_code BETWEEN 200 AND 299")

  protected

  def update_inbound_message
    inbound_message.check_status!
  end

end
