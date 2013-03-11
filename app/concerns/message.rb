require 'active_support'

module Message
  extend ActiveSupport::Concern

  module Status
    unless defined?(NEW)
      NEW = 'new'
      SENDING = 'sending'
      COMPLETED = 'completed'
    end
  end

  included do
    belongs_to :user
    belongs_to :account
    validates_presence_of :account
    before_validation :set_account_from_user

    attr_accessible :recipients_attributes

    scope :incomplete, where("#{self.quoted_table_name}.status != ? ", Status::COMPLETED)
    has_many :recipients, :dependent => :delete_all, :class_name => self.name.gsub('Message', 'Recipient'), :foreign_key => 'message_id', :order => "#{self.quoted_table_name.gsub(/MESSAGES/i, 'RECIPIENTS')}.created_at DESC"
    accepts_nested_attributes_for :recipients
  end

  def vendor
    account.send(self.class.name.gsub('Message', 'Vendor').underscore)
  end

  def worker
    vendor.worker.constantize
  end

  def create_recipients(recipient_params=[])
    recipient_params.each_with_index do |r, i|
      recipient = recipients.build(r.merge(:vendor => self.vendor))
      recipient.skip_message_validation=true
      recipient.save
      recipients.reset if i % 10 == 0
    end
  end

  def process_blacklist!
    #do nothing by default
  end

  def sendable_recipients
    recipients.to_send(vendor.id)
  end

  def sending!
    self.status = Status::SENDING
    self.sent_at = Time.now
    save!
  end

  def check_complete!
    counts = recipient_state_counts
    if val = RecipientStatus::INCOMPLETE_STATUSES.collect { |state| counts[state] }.sum == 0
      Rails.logger.debug("#{self.class.name} #{self.to_param} is complete")
      self.completed_at = recipients.most_recently_sent.first.sent_at rescue Time.now
      self.status = Status::COMPLETED
    else
      Rails.logger.debug("#{self.class.name} #{self.to_param} is not yet complete")
      self.status = Status::SENDING
    end
    save!
    val
  end

  def recipient_counts
    {'total' => recipients.count}.merge(recipient_state_counts)
  end

  protected

  def set_account_from_user
    self.account ||= self.user.account if user
  end

  def recipients_sending!
    self.recipients.update_all(status: RecipientStatus::SENDING, sent_at: Time.now)
  end

  private

  def recipient_state_counts
    groups = recipients.select('count(status) the_count, status').group('status').reorder('')
    h = Hash[groups.map { |r| [r.status, r.the_count] }]
    Hash[RecipientStatus.map { |s| [s, 0] }].merge(h)
  end
end
