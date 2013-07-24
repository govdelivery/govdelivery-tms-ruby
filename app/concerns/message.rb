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

    attr_accessor :async_recipients
    attr_accessible :recipients_attributes, :async_recipients

    scope :sending, where("#{self.quoted_table_name}.status = ? ", Status::SENDING)

    has_many :recipients, :dependent => :delete_all, :class_name => self.name.gsub('Message', 'Recipient'), :foreign_key => 'message_id', :order => "#{self.quoted_table_name.gsub(/MESSAGES/i, 'RECIPIENTS')}.created_at DESC" do
      def build_without_message(attrs)
        recipient = build(attrs)
        recipient.skip_message_validation = true
        recipient
      end
    end
    accepts_nested_attributes_for :recipients
  end

  def vendor
    account.send(self.class.name.gsub('Message', 'Vendor').underscore)
  end

  def worker
    vendor.worker.constantize
  end

  def recipient_class
    self.class.table_name.gsub(/MESSAGES/i, 'RECIPIENTS').classify.constantize
  end

  def save_with_async_recipients
    self.valid? && has_valid_async_recipients? ? save : false
  end

  ##
  # Create recipients for this message in batch. Note that this method 
  # does not return the created recipients.
  #
  # @param recipient_params [Array of Hashes]
  # @return recipient_params
  # 
  def create_recipients(recipient_params=[])
    klass = recipient_class
    recipient_params.each_with_index do |r, i|
      # not using a relation here to avoid holding references and leaking
      recipient = klass.new(r.merge(:vendor => self.vendor, :message_id => self.id))
      recipient.skip_message_validation=true
      recipient.save
    end
  end

  # The number of seconds it took to build the recipient list for this
  # message
  def recipient_build_time
    if recipients.count > 0
      first = self.created_at
      last  = recipients.reorder("created_at desc").select("created_at").first.created_at
      (last - first)
    else
      0.0
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

  def has_valid_async_recipients?
    if async_recipients && async_recipients.is_a?(Array)
      async_recipients.delete_if { |attrs| !attrs.is_a?(Hash) }
      #if the first 500 recipients are all invalid, let's just assume things are broken
      begin
        return true if async_recipients[0, 500].any? { |attrs| self.recipients.build_without_message(attrs).valid? }
      ensure
        self.recipients.clear
      end
    end
    errors.add(:recipients, 'must contain at least one valid recipient')
    return false
  end

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
