class Message < ActiveRecord::Base
  paginates_per 50

  attr_accessible :short_body, :url, :recipients_attributes
  
  has_many :recipients, :dependent => :destroy
  accepts_nested_attributes_for :recipients

  belongs_to :user
  validates_presence_of :user
  
  validates_length_of :short_body, :maximum => 160

  delegate :vendors, :to => :user
  before_validation :verify_sms_or_voice

  def create_recipients(recipient_params=[])
    recipients << recipient_params.map do |r| 
      recipient = recipients.create(r.merge(:vendor => self.vendor))
    end
  end

  def process_blacklist!
    recipients.incomplete.blacklisted.find_each do |recipient|
      logger.debug("Marking recipient as BLACKLISTED")
      recipient.status = Recipient::STATUS_BLACKLISTED
      recipient.completed_at = Time.now
      recipient.sent_at = Time.now
      recipient.save!
    end
  end
  
  def worker
    vendor.worker.constantize
  end
  
  def verify_sms_or_voice
    errors[:base] << "cannot determine message type" if short_body.blank? == url.blank?
  end
  
  def vendor
    if short_body
      vendors.sms.first
    elsif url
      vendors.voice.first
    else
      nil
    end
  end
end
