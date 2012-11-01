class Message < ActiveRecord::Base
  paginates_per 50

  attr_accessible :short_body, :recipients_attributes
  
  has_many :recipients, :dependent => :destroy
  accepts_nested_attributes_for :recipients

  belongs_to :user
  validates_presence_of :user
  
  validates_presence_of :short_body
  validates_length_of :short_body, :maximum => 160

  delegate :vendor, :to => :user

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
end
