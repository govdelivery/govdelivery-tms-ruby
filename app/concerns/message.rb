require 'active_support'

module Message
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm column: 'status', skip_validation_on_save: true do
      state :new, initial: true
      state :queued
      state :sending
      state :completed

      event :ready do
        transitions from: :new, to: :queued, guard: :create_recipients, on_transition: [:process_blacklist!, :prepare_recipients]
      end

      event :sending do
        transitions from: :queued, to: :sending, on_transition: :on_sending
      end

      event :complete do
        transitions from: :sending, to: :completed, guard: :check_complete, on_transition: :on_complete
      end
    end

    # don't raise an error if complete! fails
    def complete_with_exception_handler!
      complete_without_exception_handler!
    rescue AASM::InvalidTransition => e
      return false
    end

    alias_method_chain :complete!, :exception_handler

    belongs_to :user
    belongs_to :account
    validates_presence_of :account
    before_validation :set_account_from_user

    attr_accessor :async_recipients
    attr_accessible :recipients_attributes, :async_recipients

    has_many :recipients, -> { order("#{self.quoted_table_name.gsub(/MESSAGES/i, 'RECIPIENTS')}.created_at DESC") },
             dependent: :delete_all,
             class_name: self.name.gsub('Message', 'Recipient'),
             foreign_key: 'message_id' do
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
  # Create recipients for this message in batch. Returns true if message has valid recipients
  #
  # @param recipient_params [Array of Hashes]
  # @return recipient_params
  # 
  def create_recipients(*args)
    recipient_params = args[0] || []
    klass            = recipient_class
    success          = false
    recipient_params.each do |r|
      # not using a relation here to avoid holding references and leaking
      recipient                         = klass.new(r.merge(vendor: self.vendor, message_id: self.id))
      recipient.skip_message_validation = true
      success                           = true if recipient.save
    end
    success || recipients.count > 0
  end

  # The number of seconds it took to build the recipient list for this
  # message
  def recipient_build_time
    if recipients.count > 0
      first = self.created_at
      last = recipients.reorder("created_at desc").select("created_at").first.created_at
      (last - first)
    else
      0.0
    end
  end

  def sendable_recipients
    recipients.to_send(vendor.id)
  end

  def recipient_counts
    {'total' => recipients.count}.merge(recipient_state_counts)
  end

  protected

  def process_blacklist!
    # noop
  end

  def prepare_recipients
    # noop
  end

  def check_complete
    counts = recipient_state_counts
    Recipient.incomplete_statuses.collect { |state| counts[state] }.sum == 0
  end

  def on_sending(*args)
    self.sent_at = Time.now
  end

  def on_complete
    self.completed_at = recipients.sent.order('completed_at DESC').first.completed_at rescue Time.now
  end

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

  private

  def recipient_state_counts
    groups = recipients.select('count(status) the_count, status').group('status').reorder('')
    h = Hash[groups.map { |r| [r.status, r.the_count] }]
    Hash[self.class.aasm.states.map(&:to_s).map { |s| [s, 0] }].merge(h)
  end
end
